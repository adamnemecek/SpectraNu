//
//  Nodes.swift
//  
//
//  Created by David Conner on 3/9/16.
//
//

import Foundation
import simd
import Fuzi
import Swinject
import ModelIO

public enum SpectraNodeType: String {
    case World = "world" // TODO: design node & object
    case Transform = "transform"
    case Asset = "asset"
    case BufferAllocator = "buffer-allocator"
    case BufferAllocatorGenerator = "buffer-allocator-generator"
    case Object = "object"
    case Mesh = "mesh"
    case MeshGenerator = "mesh-generator"
    case Submesh = "submesh"
    case SubmeshGenerator = "submesh-generator"
    // wtf submesh? not really sure how to add "attributes" to mesh using submeshes
    case Camera = "camera"
    case CameraGenerator = "camera-generator"
    case PhysicalLens = "physical-lens"
    case PhysicalImagingSurface = "physical-imaging-surface"
    case StereoscopicCamera = "stereoscopic-camera"
    case VertexAttribute = "vertex-attribute"
    case VertexDescriptor = "vertex-descriptor"
    case Material = "material"
    case MaterialProperty = "material-property"
    case ScatteringFunction = "scattering-function"
    case Texture = "texture"
    case TextureGenerator = "texture-generator"
    case TextureFilter = "texture-filter"
    case TextureSampler = "texture-sampler"
    case Light = "light"
    case LightGenerator = "light-generator"
}

public struct GeneratorArg {
    public var name: String
    public var type: String
    public var value: String
    
    // TODO: how to specify lists of arguments with generator arg

    public init(name: String, type: String, value: String) {
        self.name = name
        self.type = type
        self.value = value
    }
    
    public init(elem: XMLElement) {
        self.name = elem.attributes["name"]!
        self.type = elem.attributes["type"]!
        self.value = elem.attributes["value"]!
    }

    public enum GeneratorArgType: String {
        // TODO: decide on whether this is really necessary to enumerate types (it's not .. really)
        // - node this can really be translated in the mesh generator
        case String = "String"
        case Float = "Float"
        case Float2 = "Float2"
        case Float3 = "Float3"
        case Float4 = "Float4"
        case Int = "Int"
        case Int2 = "Int2"
        case Int3 = "Int3"
        case Int4 = "Int4"
        case Mesh = "Mesh"
    }
    
    public static func parseGenArgs(elem: XMLElement, selector: String) -> [String: GeneratorArg] {
        return elem.css(selector).reduce([:]) { (var args, el) in
            let name = el.attributes["name"]!
            args[name] = GeneratorArg(elem: el)
            return args
        }
    }

    // TODO: delete?  do i really need type checking for generator args?

    //    public func parseValue<T>() -> T? {
    // TODO: populate type enum
    //        switch self.type {
    //        case .Float: return Float(value) as! T
    //        case .Float2: return SpectraSimd.parseFloat2(value) as! T
    //        case .Float3: return SpectraSimd.parseFloat3(value) as! T
    //        case .Float4: return SpectraSimd.parseFloat4(value) as! T
    //        }
    // TODO: how to switch based on type
    //        switch T.self {
    //        case Float.self: return Float(value) as! T
    //        case is float2: return (value) as! T
    //        default: return nil
    //        }
    //    }
}

public class AssetNode: SpectraParserNode { // TODO: implement SpectraParserNode protocol
    public typealias NodeType = AssetNode
    public typealias MDLType = MDLAsset
    
    public var id: String?
    public var urlString: String?
    public var resource: String?
    public var vertexDescriptor: VertexDescriptorNode?
    public var bufferAllocator: String = "default"
    
    // TODO: error handling for preserveTopology
    // - (when true the constructor throws. for now, my protocol can't handle this)
    public var preserveTopology: Bool = false
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let urlString = elem.attributes["url"] { self.urlString = urlString }
        if let resource = elem.attributes["resource"] { self.resource = resource }
        if let bufferAllocId = elem.attributes["buffer-allocator"] { self.bufferAllocator = bufferAllocId }
        if let vertexDescId = elem.attributes["vertex-descriptor"] {
            self.vertexDescriptor = nodes.resolve(VertexDescriptorNode.self, name: vertexDescId)
        } // TODO: else if contains a vertexDescriptor node
          // TODO: else set to default vertexDescriptor?

        if let preserveTopology = elem.attributes["preserve-topology"] {
            let valAsBool = NSString(string: preserveTopology).boolValue
            self.preserveTopology = valAsBool
        }
    }

    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        let url = NSURL(string: self.urlString!)
        let models = containers["model"]
        let resources = containers["resources"]
        let vertexDescriptor = self.vertexDescriptor?.generate(containers, options: options)
        let bufferAllocator = resources?.resolve(MDLMeshBufferAllocator.self, name: self.bufferAllocator)

        let asset = MDLAsset(URL: url!, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)

        // TODO: change to call with preserveTopology (it throws though)

        return asset
    }

    public func copy() -> NodeType {
        let cp = AssetNode()
        cp.id = self.id
        cp.urlString = self.urlString
        cp.resource = self.resource
        cp.vertexDescriptor = self.vertexDescriptor
        cp.bufferAllocator = self.bufferAllocator
        return cp
    }
}

public class VertexAttributeNode: SpectraParserNode {
    public typealias MDLType = MDLVertexAttribute
    public typealias NodeType = VertexAttributeNode
    
    public var id: String?
    public var name: String?
    public var format: MDLVertexFormat?
    public var offset: Int = 0
    public var bufferIndex: Int = 0
    public var initializationValue: float4 = float4()
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let name = elem.attributes["name"] { self.name = name }
        if let offset = elem.attributes["offset"] { self.offset = Int(offset)! }
        if let bufferIndex = elem.attributes["buffer-index"] { self.bufferIndex = Int(bufferIndex)! }
        
        if let format = elem.attributes["format"] {
            let enumVal = nodes.resolve(SpectraEnum.self, name: "mdlVertexFormat")!.getValue(format)
            self.format = MDLVertexFormat(rawValue: enumVal)!
        }
        if let initializationValue = elem.attributes["initialization-value"] {
            self.initializationValue = SpectraSimd.parseFloat4(initializationValue)
        }
    }
    
    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        let attr = MDLVertexAttribute()
        attr.name = self.name!
        attr.format = self.format!
        attr.offset = self.offset
        attr.bufferIndex = self.bufferIndex
        attr.initializationValue = self.initializationValue
        return attr
    }
    
    public func copy() -> NodeType {
        let cp = VertexAttributeNode()
        cp.id = self.id
        cp.name = self.name
        cp.format = self.format
        cp.offset = self.offset
        cp.bufferIndex = self.bufferIndex
        cp.initializationValue = self.initializationValue
        return cp
    }
}

public class VertexDescriptorNode: SpectraParserNode {
    public typealias NodeType = VertexDescriptorNode
    public typealias MDLType = MDLVertexDescriptor
    
    public var id: String?
    public var parentDescriptor: VertexDescriptorNode?
    public var attributes: [VertexAttributeNode] = []
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let parentDescriptor = elem.attributes["parent-descriptor"] {
            let parentDesc = nodes.resolve(VertexDescriptorNode.self, name: parentDescriptor)!
            self.parentDescriptor = parentDesc
        }
        let attributeSelector = "vertex-attributes > vertex-attribute"
        for (idx, el) in elem.css(attributeSelector).enumerate() {
            if let ref = el.attributes["ref"] {
                let vertexAttr = nodes.resolve(VertexAttributeNode.self, name: ref)!
                attributes.append(vertexAttr)
            } else {
                let vertexAttr = VertexAttributeNode()
                vertexAttr.parseXML(nodes, elem: el)
                attributes.append(vertexAttr)
            }
        }
    }
    
    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        var desc = parentDescriptor?.generate(containers, options: options) ?? MDLVertexDescriptor()
        
        for attr in self.attributes {
            let vertexAttr = attr.generate(containers, options: options)
            desc.addOrReplaceAttribute(vertexAttr)
        }
        
        // this automatically sets the offset correctly,
        // - but attributes must be assigned and configured by this point
        desc.setPackedOffsets()
        desc.setPackedStrides()
        
        return desc
    }
    
    public func copy() -> VertexDescriptorNode {
        let cp = VertexDescriptorNode()
        cp.id = self.id
        cp.attributes = self.attributes
        cp.parentDescriptor = self.parentDescriptor
        return cp
    }
    
}

public class TransformNode: SpectraParserNode {
    public typealias NodeType = TransformNode
    public typealias MDLType = MDLTransform
    
    public var id: String?
    public var scale: float3 = float3(1.0, 1.0, 1.0)
    public var rotation: float3 = float3(0.0, 0.0, 0.0)
    public var translation: float3 = float3(0.0, 0.0, 0.0)
    public var shear: float3 = float3(0.0, 0.0, 0.0)
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        // N.B. scale first, then rotate, finally translate
        // - but how can a shear operation be composed into this?
        if let id = elem.attributes["id"] { self.id = id }
        if let scale = elem.attributes["scale"] { self.scale = SpectraSimd.parseFloat3(scale) }
        if let shear = elem.attributes["shear"] { self.shear = SpectraSimd.parseFloat3(shear) }
        if let translation = elem.attributes["translation"] { self.translation = SpectraSimd.parseFloat3(translation) }
        
        if let rotation = elem.attributes["rotation"] {
            self.rotation = SpectraSimd.parseFloat3(rotation)
        } else if let rotationDeg = elem.attributes["rotation-deg"] {
            let rotationDegrees = SpectraSimd.parseFloat3(rotationDeg)
            self.rotation = Float(M_PI / 180.0) * rotationDegrees
        }
    }

    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        let transform = MDLTransform()
        transform.scale = self.scale
        transform.shear = self.shear
        transform.rotation = self.rotation
        transform.translation = self.translation
        return transform
    }
    
    public func copy() -> TransformNode {
        let cp = TransformNode()
        cp.id = self.id
        cp.scale = self.scale
        cp.shear = self.shear
        cp.rotation = self.rotation
        cp.translation = self.translation
        return cp
    }
    
}

// TODO: BufferAllocator = "buffer-allocator"
// TODO: BufferAllocatorGenerator = "buffer-allocator-generator"


public class ObjectNode { // SpectraParserNode
    // stub
}

public class MeshNode: SpectraParserNode {
    public typealias NodeType = MeshNode
    public typealias MDLType = MDLMesh
    
    public var id: String?
    public var generator: String = "ellipsoid_mesh_gen"
    public var args: [String: GeneratorArg] = [:]
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(container: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let generator = elem.attributes["generator"] { self.generator = generator }
        let genArgsSelector = "generator-args > generator-arg"
        self.args = GeneratorArg.parseGenArgs(elem, selector: genArgsSelector)
    }
    
    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        let models = containers["models"]!
        let meshGen = models.resolve(MeshGenerator.self, name: self.generator)!
        let mesh = meshGen.generate(models, args: self.args)
        // TODO: register mesh?
        return mesh
    }
    
    public func copy() -> NodeType {
        let cp = MeshNode()
        cp.id = self.id
        cp.generator = self.generator
        cp.args = self.args
        return cp
    }
    
}

public class MeshGeneratorNode: SpectraParserNode {
    public typealias NodeType = MeshGeneratorNode
    public typealias MDLType = MeshGenerator
    
    public var id: String?
    public var type: String = "tetrahedron_mesh_gen"
    public var args: [String: GeneratorArg] = [:]
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(container: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let type = elem.attributes["type"] { self.type = type }
        let genArgsSelector = "generator-args > generator-arg"
        self.args = GeneratorArg.parseGenArgs(elem, selector: genArgsSelector)
    }

//    public func createGenerator(container: Container, options: [String : Any] = [:]) -> MeshGenerator {
//        let meshGen = container.resolve(MeshGenerator.self, name: self.type)!
//        meshGen.processArgs(container, args: self.args)
//        return meshGen
//    }

    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        // TODO: add to a generators container instead?
        let models = containers["models"]!
        let meshGen = models.resolve(MeshGenerator.self, name: self.type)!
        meshGen.processArgs(models, args: self.args)
        return meshGen
    }
    
    public func copy() -> NodeType {
        let cp = MeshGeneratorNode()
        cp.id = self.id
        cp.type = self.type
        cp.args = self.args
        return cp
    }
}

public class SubmeshNode: SpectraParserNode {
    public typealias NodeType = SubmeshNode
    public typealias MDLType = MDLSubmesh
    
    public var id: String?
    public var generator: String = "tetrahedron_mesh_gen"
    public var args: [String: GeneratorArg] = [:]
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let generator = elem.attributes["generator"] { self.generator = generator }
        let genArgsSelector = "generator-args > generator-arg"
        self.args = GeneratorArg.parseGenArgs(elem, selector: genArgsSelector)
    }
    
    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        let models = containers["models"]!
        let submeshGen = models.resolve(SubmeshGenerator.self, name: self.generator)!
        let submesh = submeshGen.generate(models, args: self.args)
        // TODO: register submesh?
        return submesh
    }
    
//    // TODO: add to a generators container instead?
//    let models = containers["models"]!
//    let submeshGen = models.resolve(SubmeshGenerator.self, name: self.type)!
//    submeshGen.processArgs(models, args: self.args)
//    return submeshGen
    
    public func copy() -> NodeType {
        let cp = SubmeshNode()
        cp.id = self.id
        cp.generator = self.generator
        cp.args = self.args
        return cp
    }
}

public class SubmeshGeneratorNode: SpectraParserNode {
    public typealias NodeType = SubmeshGeneratorNode
    public typealias MDLType = SubmeshGenerator
    
    public var id: String?
    public var type: String = "random_balanced_graph_submesh_gen"
    public var args: [String: GeneratorArg] = [:]
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(container: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let type = elem.attributes["type"] { self.type = type }
        let genArgsSelector = "generator-args > generator-arg"
        self.args = GeneratorArg.parseGenArgs(elem, selector: genArgsSelector)
    }
    
    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        // TODO: add to a generators container instead?
        let models = containers["models"]!
        let meshGen = models.resolve(SubmeshGenerator.self, name: self.type)!
        meshGen.processArgs(models, args: self.args)
        // TODO: register submeshGen?
        return meshGen
    }
    
    public func copy() -> NodeType {
        let cp = SubmeshGeneratorNode()
        cp.id = self.id
        cp.type = self.type
        cp.args = self.args
        return cp
    }

}

// TODO: submeshes: not really sure how to add "attributes" to mesh using submeshes

public class PhysicalLensNode: SpectraParserNode {
    public typealias MDLType = PhysicalLensNode
    public typealias NodeType = PhysicalLensNode
    
    // for any of this to do anything, renderer must support the math (visual distortion, etc)
    
    public var id: String?
    public var worldToMetersConversionScale: Float?
    public var barrelDistortion: Float?
    public var fisheyeDistortion: Float?
    public var opticalVignetting: Float?
    public var chromaticAberration: Float?
    public var focalLength: Float?
    public var fStop: Float?
    public var apertureBladeCount: Int?
    public var maximumCircleOfConfusion: Float?
    public var focusDistance: Float?

    // defaults
    public static let worldToMetersConversionScale: Float = 1.0
    public static let barrelDistortion: Float = 0
    public static let fisheyeDistortion: Float = 0
    public static let opticalVignetting: Float = 0
    public static let chromaticAberration: Float = 0
    public static let focalLength: Float = 50
    public static let fStop: Float = 5.6
    public static let apertureBladeCount: Int = 0
    public static let maximumCircleOfConfusion: Float = 0.05
    public static let focusDistance: Float = 2.5
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    // doc's don't list default shutterOpenInterval value,
    // - but (1/60) * 0.50 = 1/120 for 60fps and 50% shutter
    public var shutterOpenInterval: NSTimeInterval = (0.5 * (1.0/60.0))

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let val = elem.attributes["world-to-meters-conversion-scale"] { self.worldToMetersConversionScale = Float(val)! }
        if let val = elem.attributes["barrel-distortion"] { self.barrelDistortion = Float(val)! }
        if let val = elem.attributes["fisheye-distortion"] { self.fisheyeDistortion = Float(val)! }
        if let val = elem.attributes["optical-vignetting"] { self.opticalVignetting = Float(val)! }
        if let val = elem.attributes["chromatic-aberration"] { self.chromaticAberration = Float(val)! }
        if let val = elem.attributes["focal-length"] { self.focalLength = Float(val)! }
        if let val = elem.attributes["f-stop"] { self.fStop = Float(val)! }
        if let val = elem.attributes["aperture-blade-count"] { self.apertureBladeCount = Int(val)! }
        if let val = elem.attributes["maximum-circle-of-confusion"] { self.maximumCircleOfConfusion = Float(val)! }
        if let val = elem.attributes["focus-distance"] { self.focusDistance = Float(val)! }
    }

    public func applyToCamera(camera: MDLCamera) {
        if let val = self.worldToMetersConversionScale { camera.worldToMetersConversionScale = val }
        if let val = self.barrelDistortion { camera.barrelDistortion = val }
        if let val = self.fisheyeDistortion { camera.fisheyeDistortion = val }
        if let val = self.opticalVignetting { camera.opticalVignetting = val }
        if let val = self.chromaticAberration { camera.chromaticAberration = val }
        if let val = self.focalLength { camera.focalLength = val }
        if let val = self.fStop { camera.fStop = val }
        if let val = self.apertureBladeCount { camera.apertureBladeCount = val }
        if let val = self.maximumCircleOfConfusion { camera.maximumCircleOfConfusion = val }
        if let val = self.focusDistance { camera.focusDistance = val }
    }
    
    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        return self.copy()
    }

    public func copy() -> NodeType {
        let cp = PhysicalLensNode()
        cp.id = self.id
        cp.worldToMetersConversionScale = self.worldToMetersConversionScale
        cp.barrelDistortion = self.barrelDistortion
        cp.fisheyeDistortion = self.fisheyeDistortion
        cp.opticalVignetting = self.opticalVignetting
        cp.chromaticAberration = self.chromaticAberration
        cp.focalLength = self.focalLength
        cp.fStop = self.fStop
        cp.apertureBladeCount = self.apertureBladeCount
        cp.maximumCircleOfConfusion = self.maximumCircleOfConfusion
        cp.focusDistance = self.focusDistance
        return cp
    }
}

public class PhysicalImagingSurfaceNode: SpectraParserNode {
    public typealias NodeType = PhysicalImagingSurfaceNode
    public typealias MDLType = PhysicalImagingSurfaceNode
    
    // for any of this to do anything, renderer must support the math (visual distortion, etc)

    public var id: String?
    public var sensorVerticalAperture: Float?
    public var sensorAspect: Float?
    public var sensorEnlargement: vector_float2?
    public var sensorShift: vector_float2?
    public var flash: vector_float3?
    public var exposure: vector_float3?
    public var exposureCompression: vector_float2?

    // defaults
    public static let sensorVerticalAperture: Float = 24
    public static let sensorAspect: Float = 1.5
    public static let sensorEnlargement: vector_float2 = float2(1.0, 1.0)
    public static let sensorShift: vector_float2 = float2(0.0, 0.0)
    public static let flash: vector_float3 = float3(0.0, 0.0, 0.0)
    public static let exposure: vector_float3 = float3(1.0, 1.0, 1.0)
    public static let exposureCompression: vector_float2 = float2(1.0, 0.0)
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let val = elem.attributes["sensor-vertical-aperture"] { self.sensorVerticalAperture = Float(val) }
        if let val = elem.attributes["sensor-aspect"] { self.sensorAspect = Float(val) }
        if let val = elem.attributes["sensor-enlargement"] { self.sensorEnlargement = SpectraSimd.parseFloat2(val) }
        if let val = elem.attributes["sensor-shift"] { self.sensorShift = SpectraSimd.parseFloat2(val) }
        if let val = elem.attributes["flash"] { self.flash = SpectraSimd.parseFloat3(val) }
        if let val = elem.attributes["exposure"] { self.exposure = SpectraSimd.parseFloat3(val) }
        if let val = elem.attributes["exposure-compression"] { self.exposureCompression = SpectraSimd.parseFloat2(val) }
    }

    public func applyToCamera(camera: MDLCamera) {
        if let val = self.sensorVerticalAperture { camera.sensorVerticalAperture = val }
        if let val = self.sensorAspect { camera.sensorAspect = val }
        if let val = self.sensorEnlargement {camera.sensorEnlargement = val }
        if let val = self.sensorShift {camera.sensorShift = val }
        if let val = self.flash {camera.flash = val }
        if let val = self.exposure {camera.exposure = val }
        if let val = self.exposureCompression {camera.exposureCompression = val }
    }
    
    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        return self.copy()
    }

    public func copy() -> NodeType {
        let cp = PhysicalImagingSurfaceNode()
        cp.id = self.id
        cp.sensorVerticalAperture = self.sensorVerticalAperture
        cp.sensorAspect = self.sensorAspect
        cp.sensorEnlargement = self.sensorEnlargement
        cp.sensorShift = self.sensorShift
        cp.flash = self.flash
        cp.exposure = self.exposure
        cp.exposureCompression = self.exposureCompression
        return cp
    }
}

public class CameraNode: SpectraParserNode {
    public typealias MDLType = MDLCamera
    public typealias NodeType = CameraNode
    
    public var id: String?
    public var nearVisibilityDistance: Float = 0.1
    public var farVisibilityDistance: Float = 1000.0
    public var fieldOfView: Float = Float(53.999996185302734375)
    
    public var lookAt: float3?
    public var lookFrom: float3?
    
    public var physicalLens = PhysicalLensNode()
    public var physicalImagingSurface = PhysicalImagingSurfaceNode()
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let val = elem.attributes["near-visibility-distance"] { self.nearVisibilityDistance = Float(val)! }
        if let val = elem.attributes["far-visibility-distance"] { self.farVisibilityDistance = Float(val)! }
        if let val = elem.attributes["field-of-view"] { self.fieldOfView = Float(val)! }
        
        let lensSelector = SpectraNodeType.PhysicalLens.rawValue
        if let lensTag = elem.firstChild(tag: lensSelector) {
            if let ref = lensTag.attributes["ref"] {
                let lens = nodes.resolve(PhysicalLensNode.self, name: ref)!
                self.physicalLens = lens
            } else {
                let lens = PhysicalLensNode()
                lens.parseXML(nodes, elem: lensTag)
                if let lensId = lensTag["id"] {
                    nodes.register(PhysicalLensNode.self, name: lensId) { _ in return
                        lens.copy() as! PhysicalLensNode
                    }
                }
                self.physicalLens = lens
            }
        }

        let imagingSelector = SpectraNodeType.PhysicalImagingSurface.rawValue
        if let imagingTag = elem.firstChild(tag: imagingSelector) {
            if let ref = imagingTag.attributes["ref"] {
                let imgSurface = nodes.resolve(PhysicalImagingSurfaceNode.self, name: ref)!
                self.physicalImagingSurface = imgSurface
            } else {
                let imgSurface = PhysicalImagingSurfaceNode()
                imgSurface.parseXML(nodes, elem: imagingTag)
                if let imagingSurfaceId = imagingTag["id"] {
                    nodes.register(PhysicalImagingSurfaceNode.self, name: imagingTag["id"]!) { _ in
                        return imgSurface.copy() as! PhysicalImagingSurfaceNode
                    }
                }
                self.physicalImagingSurface = imgSurface
            }
        }

        if let lookAtAttr = elem.attributes["look-at"] { self.lookAt = SpectraSimd.parseFloat3(lookAtAttr) }
        if let lookFromAttr = elem.attributes["look-from"] { self.lookFrom = SpectraSimd.parseFloat3(lookFromAttr) }
    }
    
    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        let cam = MDLCamera()
        
        cam.nearVisibilityDistance = self.nearVisibilityDistance
        cam.farVisibilityDistance = self.farVisibilityDistance
        cam.fieldOfView = self.fieldOfView
        
        self.physicalLens.applyToCamera(cam)
        self.physicalImagingSurface.applyToCamera(cam)
        
        if lookAt != nil {
            if lookFrom != nil {
                cam.lookAt(self.lookAt!)
            } else {
                cam.lookAt(self.lookAt!, from: self.lookFrom!)
            }
        }
        
        return cam
    }
    
    public func copy() -> NodeType {
        let cp = CameraNode()
        cp.id = self.id
        cp.nearVisibilityDistance = self.nearVisibilityDistance
        cp.farVisibilityDistance = self.farVisibilityDistance
        cp.fieldOfView = self.fieldOfView
        
        cp.lookAt = self.lookAt
        cp.lookFrom = self.lookFrom
        
        cp.physicalLens = self.physicalLens
        cp.physicalImagingSurface = self.physicalImagingSurface
        
        return cp
    }
}

public class StereoscopicCameraNode: SpectraParserNode {
    public typealias MDLType = MDLStereoscopicCamera
    public typealias NodeType = StereoscopicCameraNode

    public var id: String?
    public var nearVisibilityDistance: Float = 0.1
    public var farVisibilityDistance: Float = 1000.0
    public var fieldOfView: Float = Float(53.999996185302734375)
    
    public var physicalLens = PhysicalLensNode()
    public var physicalImagingSurface = PhysicalImagingSurfaceNode()
    
    public var lookAt: float3?
    public var lookFrom: float3?
    
    public var interPupillaryDistance: Float = 63.0
    public var leftVergence: Float = 0.0
    public var rightVergence: Float = 0.0
    public var overlap: Float = 0.0
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        let cam = CameraNode()
        cam.parseXML(nodes, elem: elem)
        let stereoCam = applyCameraToStereoscopic(cam)
        
        if let interPupillaryDistance = elem.attributes["inter-pupillary-distance"] { self.interPupillaryDistance = Float(interPupillaryDistance)! }
        if let leftVergence = elem.attributes["left-vergence"] { self.leftVergence = Float(leftVergence)! }
        if let rightVergence = elem.attributes["right-vergence"] { self.rightVergence = Float(rightVergence)! }
        if let overlap = elem.attributes["overlap"] { self.overlap = Float(overlap)! }
    }
 
    public func applyCameraToStereoscopic(cam: CameraNode) {
        self.id = cam.id
        self.nearVisibilityDistance = cam.nearVisibilityDistance
        self.farVisibilityDistance = cam.farVisibilityDistance
        self.fieldOfView = cam.fieldOfView
        
        self.physicalLens = cam.physicalLens
        self.physicalImagingSurface = cam.physicalImagingSurface
        
        self.lookAt = cam.lookAt
        self.lookFrom = cam.lookFrom
    }

    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        let cam = MDLStereoscopicCamera()
        
        cam.nearVisibilityDistance = self.nearVisibilityDistance
        cam.farVisibilityDistance = self.farVisibilityDistance
        cam.fieldOfView = self.fieldOfView
        
        cam.interPupillaryDistance = self.interPupillaryDistance
        cam.leftVergence = self.leftVergence
        cam.rightVergence = self.rightVergence
        cam.overlap = self.overlap
        
        self.physicalLens.applyToCamera(cam)
        self.physicalImagingSurface.applyToCamera(cam)
        
        if lookAt != nil {
            if lookFrom != nil {
                cam.lookAt(self.lookAt!)
            } else {
                cam.lookAt(self.lookAt!, from: self.lookFrom!)
            }
        }
        
        return cam
    }
    
    public func copy() -> NodeType {
        let cp = StereoscopicCameraNode()
        cp.id = self.id
        cp.nearVisibilityDistance = self.nearVisibilityDistance
        cp.farVisibilityDistance = self.farVisibilityDistance
        cp.fieldOfView = self.fieldOfView
        
        cp.lookAt = self.lookAt
        cp.lookFrom = self.lookFrom
        
        cp.physicalLens = self.physicalLens
        cp.physicalImagingSurface = self.physicalImagingSurface
        
        return cp
    }
}

// TODO: Material = "material"
// TODO: MaterialProperty = "material-property"
// TODO: ScatteringFunction = "scattering-function"

public class TextureNode: SpectraParserNode {
    public typealias NodeType = TextureNode
    public typealias MDLType = MDLTexture
    
    public var id: String?
    public var generator: String = "noise_texture_gen"
    public var args: [String: GeneratorArg] = [:]
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(container: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let generator = elem.attributes["generator"] { self.generator = generator }
        let genArgsSelector = "generator-args > generator-arg"
        self.args = GeneratorArg.parseGenArgs(elem, selector: genArgsSelector)
    }
    
    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        let models = containers["models"]!
        let textureGen = models.resolve(TextureGenerator.self, name: self.generator)!
        let texture = textureGen.generate(models, args: self.args)
        // TODO: register texture?
//        container.register(MDLTexture.self, name: id!) { _ in
//            // don't copy texture
//            return texture
//        }
        return texture
    }
    
    public func copy() -> NodeType {
        let cp = TextureNode()
        cp.id = self.id
        cp.generator = self.generator
        cp.args = self.args
        return cp
    }
}

public class TextureGeneratorNode: SpectraParserNode {
    public typealias NodeType = TextureGeneratorNode
    public typealias MDLType = TextureGenerator
    
    public var id: String?
    public var type: String = "noise_texture_gen"
    public var args: [String: GeneratorArg] = [:]
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(container: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let type = elem.attributes["type"] { self.type = type }
        let genArgsSelector = "generator-args > generator-arg"
        self.args = GeneratorArg.parseGenArgs(elem, selector: genArgsSelector)
    }
    
    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        // TODO: add to a generators container instead?
        let models = containers["models"]!
        let texGen = models.resolve(TextureGenerator.self, name: self.type)!
        texGen.processArgs(models, args: self.args)
        return texGen
    }

    public func copy() -> NodeType {
        let cp = TextureGeneratorNode()
        cp.id = self.id
        cp.type = self.type
        cp.args = self.args
        return cp
    }
}

public class TextureFilterNode: SpectraParserNode {
    public typealias NodeType = TextureFilterNode
    public typealias MDLType = MDLTextureFilter
    
    public var id: String?
    public var rWrapMode = MDLMaterialTextureWrapMode.Clamp
    public var tWrapMode = MDLMaterialTextureWrapMode.Clamp
    public var sWrapMode = MDLMaterialTextureWrapMode.Clamp
    public var minFilter = MDLMaterialTextureFilterMode.Nearest
    public var magFilter = MDLMaterialTextureFilterMode.Nearest
    public var mipFilter = MDLMaterialMipMapFilterMode.Nearest
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let rWrap = elem.attributes["r-wrap-mode"] {
            let enumVal = nodes.resolve(SpectraEnum.self, name: "mdlMaterialTextureWrapMode")!.getValue(rWrap)
            self.rWrapMode = MDLMaterialTextureWrapMode(rawValue: enumVal)!
        }
        if let tWrap = elem.attributes["t-wrap-mode"] {
            let enumVal = nodes.resolve(SpectraEnum.self, name: "mdlMaterialTextureWrapMode")!.getValue(tWrap)
            self.tWrapMode = MDLMaterialTextureWrapMode(rawValue: enumVal)!
        }
        if let sWrap = elem.attributes["s-wrap-mode"] {
            let enumVal = nodes.resolve(SpectraEnum.self, name: "mdlMaterialTextureWrapMode")!.getValue(sWrap)
            self.sWrapMode = MDLMaterialTextureWrapMode(rawValue: enumVal)!
        }
        if let minFilter = elem.attributes["min-filter"] {
            let enumVal = nodes.resolve(SpectraEnum.self, name: "mdlMaterialTextureFilterMode")!.getValue(minFilter)
            self.minFilter = MDLMaterialTextureFilterMode(rawValue: enumVal)!
        }
        if let magFilter = elem.attributes["mag-filter"] {
            let enumVal = nodes.resolve(SpectraEnum.self, name: "mdlMaterialTextureFilterMode")!.getValue(magFilter)
            self.magFilter = MDLMaterialTextureFilterMode(rawValue: enumVal)!
        }
        if let mipFilter = elem.attributes["mip-filter"] {
            let enumVal = nodes.resolve(SpectraEnum.self, name: "mdlMaterialMipMapFilterMode")!.getValue(mipFilter)
            self.mipFilter = MDLMaterialMipMapFilterMode(rawValue: enumVal)!
        }
    }

    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        let filter = MDLTextureFilter()

        filter.rWrapMode = self.rWrapMode
        filter.tWrapMode = self.tWrapMode
        filter.sWrapMode = self.sWrapMode
        filter.minFilter = self.minFilter
        filter.magFilter = self.magFilter
        filter.mipFilter = self.mipFilter

        return filter
    }

    public func copy() -> NodeType {
        let cp = TextureFilterNode()
        cp.id = self.id
        cp.rWrapMode = self.rWrapMode
        cp.tWrapMode = self.tWrapMode
        cp.sWrapMode = self.sWrapMode
        cp.minFilter = self.minFilter
        cp.magFilter = self.magFilter
        cp.mipFilter = self.mipFilter
        return cp
    }
}

public class TextureSamplerNode: SpectraParserNode {
    public typealias NodeType = TextureSamplerNode
    public typealias MDLType = MDLTextureSampler
    
    public var id: String?
    public var texture: String?
    public var hardwareFilter: String?
    public var transform: String?
    
    init() {
        
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    // public func parseJSON()
    // public func parsePlist()
    // public func parseXML(nodeContainer: Container)
    
    // so, as above ^^^ there would instead be a nodeContainer, for parsing SpectraXML
    // - this would just contain very easily copyable definitions of nodes - no Model I/O
    // - these nodes could also instead be structs
    // - these nodes could generate the Model I/O, whenever app developer wants
    //   - the generate method would instead receive a different container.
    //     - but, does this really work?
    //     - (parsing works now because it's assumed
    //     - to proceed in the order which things are declared)
    // - having a separate nodeContainer ensures that each dependency registered
    //   - can be totally self-contained
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        if let id = elem.attributes["id"] { self.id = id }
        if let texture = elem.attributes["texture"] { self.texture = texture }
        if let hardwareFilter = elem.attributes["hardware-filter"] { self.hardwareFilter = hardwareFilter }
        if let transform = elem.attributes["transform"] { self.transform = transform }
    }
    
    public func generate(containers: [String: Container] = [:], options: [String: Any] = [:], injector: GeneratorClosure? = nil) -> MDLType {
        let models = containers["model"]!
        
        let sampler = MDLTextureSampler()
        sampler.texture = models.resolve(MDLTexture.self, name: self.texture)
        sampler.hardwareFilter = models.resolve(MDLTextureFilter.self, name: self.texture)
        if let transform = models.resolve(MDLTransform.self, name: self.transform) {
            sampler.transform = transform
        } else {
            sampler.transform = MDLTransform()
        }
        
        return sampler
    }
    
    public func copy() -> NodeType {
        let cp = TextureSamplerNode()
        cp.id = self.id
        cp.texture = self.texture
        cp.hardwareFilter = self.hardwareFilter
        cp.transform = self.transform
        return cp
    }
    
//    // implemented copy() as a static method for compatibility for now
//    public static func copy(obj: MDLTextureSampler) -> MDLTextureSampler {
//        let cp = MDLTextureSampler()
//        cp.texture = obj.texture // can't really copy textures for resource reasons
//        cp.transform = obj.transform ?? MDLTransform()
//        if let filter = obj.hardwareFilter {
//            cp.hardwareFilter = TextureFilterNode.copy(filter)
//        }
//        return cp
//    }
}

// TODO: Light = "light"
// TODO: LightGenerator = "light-generator"

