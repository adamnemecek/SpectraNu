//
//  Parser.swift
//  
//
//  Created by David Conner on 3/9/16.
//
//

import Foundation
import Swinject
import Fuzi
import ModelIO

// GeneratorClosure =~ RegisterClosure
// - they both transform the containers and options passed into generate & register
// - they're both optional
// - i need some way for each node type to "declare" the options it needs to be available
//   - as well as a function for default transformation 4 resolving params from [String: Container]

// problems: how to pass the GeneratorClosures down through the tree of nodes (if necessary)
// - for now, just passing nil down the tree, but allowing the following order for resolving params for generate
//   - (1) if closure exists, run & set params from the resulting Container Map & Options Map.
//     - this closure is only passed to the top level node for now.  
//     - it's possible to pass thru to the child nodes.  maybe later
//     - need a kind of inverted-map structure for options
//   - (2) if not, then if necessary params are defined in the Options Map, set the params 4 generate from those
//     - how to distinguish the params defined in option for a parent node and child nodes
//   - (3) otherwise, run the default behavior for fetching params from Container Map
// ...
public typealias GeneratorClosure = ((containers: [String: Container], options: [String: Any]?) ->
    (containers: [String: Container], options: [String: Any]?))
public typealias RegisterClosure = (containers: [String: Container], options: [String: Any]) -> (containers: [String: Container], options: [String: Any]?)

public protocol SpectraParserNode {
    typealias NodeType
    typealias MDLType
    
    var id: String? { get set }
    // requires init() for copy()
    init(nodes: Container, elem: XMLElement)
    func parseXML(nodes: Container, elem: XMLElement)
    func generate(containers: [String: Container], options: [String: Any]) -> MDLType
    func register(nodes: Container, objectScope: ObjectScope)
    func copy() -> NodeType
}

extension SpectraParserNode {
    public func register(nodes: Container, objectScope: ObjectScope = .None) {
        let nodeCopy = self.copy()
        nodes.register(NodeType.self, name: self.id!) { _ in
            return nodeCopy
            }.inObjectScope(objectScope)
    }
}

public class SpectraParser {
    public var nodes: Container
    
    public init(nodes: Container = Container()) {
        self.nodes = nodes
    }
    
    public func getAsset(id: String?) -> AssetNode? {
        return nodes.resolve(AssetNode.self, name: id)
    }
    
    public func getVertexAttribute(id: String?) -> VertexAttributeNode? {
        return nodes.resolve(VertexAttributeNode.self, name: id)
    }
    
    public func getVertexDescriptor(id: String?) -> VertexDescriptorNode? {
        return nodes.resolve(VertexDescriptorNode.self, name: id)
    }
    
    public func getTransform(id: String?) -> TransformNode? {
        return nodes.resolve(TransformNode.self, name: id)
    }
    
    public func getObject(id: String?) -> ObjectNode? {
        return nodes.resolve(ObjectNode.self, name: id)
    }
    
    public func getPhysicalLens(id: String?) -> PhysicalLensNode? {
        return nodes.resolve(PhysicalLensNode.self, name: id)
    }
    
    public func getPhysicalImagingSurface(id: String?) -> PhysicalImagingSurfaceNode? {
        return nodes.resolve(PhysicalImagingSurfaceNode.self, name: id)
    }
    
    public func getCamera(id: String?) -> CameraNode? {
        return nodes.resolve(CameraNode.self, name: id)
    }
    
    public func getStereoscopicCamera(id: String?) -> StereoscopicCameraNode? {
        return nodes.resolve(StereoscopicCameraNode.self, name: id)
    }
    
    public func getMesh(id: String?) -> MeshNode? {
        return nodes.resolve(MeshNode.self, name: id)
    }
    
    public func getMeshGenerator(id: String?) -> MeshGeneratorNode? {
        return nodes.resolve(MeshGeneratorNode.self, name: id)
    }
    
    public func getSubmesh(id: String?) -> SubmeshNode? {
        return nodes.resolve(SubmeshNode.self, name: id)
    }
    
    public func getSubmeshGenerator(id: String?) -> SubmeshGeneratorNode? {
        return nodes.resolve(SubmeshGeneratorNode.self, name: id)
    }
    
    public func getTexture(id: String?) -> TextureNode? {
        return nodes.resolve(TextureNode.self, name: id)
    }
    
    public func getTextureGenerator(id: String?) -> TextureGeneratorNode? {
        return nodes.resolve(TextureGeneratorNode.self, name: id)
    }
    
    public func getTextureFilter(id: String?) -> TextureFilterNode? {
        return nodes.resolve(TextureFilterNode.self, name: id)
    }
    
    public func getTextureSampler(id: String?) -> TextureSamplerNode? {
        return nodes.resolve(TextureSamplerNode.self, name: id)
    }
    
    // TODO: Material
    // TODO: MaterialProperty
    // TODO: ScatteringFunction
    // TODO: Light
    // TODO: LightGenerator

//    public func get(id: String?) -> Node? {
//        return nodes.resolve(Node.self, name: id)
//    }
    
    // public func parseJSON()
    // public func parsePList()
    
    public func parseXML(xml: XMLDocument) {
        for child in xml.root!.children {
            let (tag, id) = (child.tag!, child.attributes["id"])
            
            // TODO: how to refactor this giant switch statement
            if let nodeType = SpectraNodeType(rawValue: tag) {
                
                switch nodeType {
                case .Asset:
                    let node = AssetNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .VertexAttribute:
                    let node = VertexAttributeNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .VertexDescriptor:
                    let node = VertexDescriptorNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .Transform:
                    let node = TransformNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
//                case .Object:
//                    let node = ObjectNode(nodes: nodes, elem: child)
//                    if (node.id != nil) { node.register(nodes) }
                case .PhysicalLens:
                    let node = PhysicalLensNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .PhysicalImagingSurface:
                    let node = PhysicalImagingSurfaceNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .Camera:
                    let node = CameraNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .StereoscopicCamera:
                    let node = StereoscopicCameraNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .Mesh:
                    let node = MeshNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .MeshGenerator:
                    let node = MeshGeneratorNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .Submesh:
                    let node = SubmeshNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .SubmeshGenerator:
                    let node = SubmeshGeneratorNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .Texture:
                    let node = TextureNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
//                case .TextureGenerator: break
                case .TextureFilter:
                    let node = TextureFilterNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
//                case .TextureSampler: break
//                case .Material: break
//                case .MaterialProperty: break
//                case .ScatteringFunction: break
//                case .Light: break
//                case .LightGenerator: break
                default: break
                }
            }
        }
    }
    
    public static func readXML(bundle: NSBundle, filename: String, bundleResourceName: String?) -> XMLDocument? {
        var resourceBundle: NSBundle = bundle
        if let resourceName = bundleResourceName {
            let bundleURL = bundle.URLForResource(resourceName, withExtension: "bundle")
            resourceBundle = NSBundle(URL: bundleURL!)!
        }

        let path = resourceBundle.pathForResource(filename, ofType: "xml")
        let data = NSData(contentsOfFile: path!)
        
        do {
            return try XMLDocument(data: data!)
        } catch let err as XMLError {
            switch err {
            case .ParserFailure, .InvalidData: print(err)
            case .LibXMLError(let code, let message): print("libxml error code: \(code), message: \(message)")
            default: break
            }
        } catch let err {
            print("error: \(err)")
        }
        return nil
    }
}

//public class SpectraXML {
//    var xml: XMLDocument?
//    var parser: Container
//
//    public init(parser: Container, data: NSData) {
//        // NOTE: both this parser and the container injected into the SpectraXMLNodeParser functions
//        // - should be able to reference the enum types read from the XSD file
//        // - the simplest way to do this is create a container, load the XSD enums onto it,
//        //   - then use this parser container as a parent: nodeParserContainer = Container(parent: parser)
//        //   - refer to SpectraXMLSpec for an example
//        // - or, if scoping is an issue, apply the enums to both the parser & nodeParser containers
//        self.parser = parser
//
//        do {
//            xml = try XMLDocument(data: data)
//        } catch let err as XMLError {
//            switch err {
//            case .ParserFailure, .InvalidData: print(err)
//            case .LibXMLError(let code, let message): print("libxml error code: \(code), message: \(message)")
//            default: break
//            }
//        } catch let err {
//            print("error: \(err)")
//        }
//    }
//
//    public class func initParser(parser: Container) -> Container {
//        //TODO: how to ensure that typing is consistent?
//        // return [fnParse -> Any, fnCast -> MDLType] // this may work
//
//        // yes, the design's a bit convoluted, but allows great flexibility!
//        // - note: with great flexibility, comes great responsibility!!
//        //   - this is true, both from a performance aspect (reference retention)
//        // - as well as from a security aspect (arbitrary execution from remote XML)
//        //   - spectra is intended as a LEARNING TOOL ONLY at this point.
//
//        // NOTE: you can override default behavior by returning an alternative closure
//        // - just do parser.register() and override.
//        // - you can also do newParser = Container(parent: parser)
//        //   - and then create a tree of custom parsers (see Swinject docs)
//
//        // NOTE: if you do override default behavior for nodes: beware scoping
//        // - if you pass node into the closure that's returned, it will stick around
//        //   - instead just use node to determine which closure to return
//        //   - that closure will get the node anyways
//        // - same thing with options: beware retaining a reference
//
//        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.VertexAttribute.rawValue) { (r, k: String, node: XMLElement, options: [String: Any]) in
//            return SpectraXMLNodeType.VertexAttribute.nodeParser(node, key: k, options: options)!
//            }.inObjectScope(.None) // always return a new instance of the closure
//
//        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.VertexDescriptor.rawValue) { (r, k: String, node: XMLElement, options: [String:Any]) in
//            return SpectraXMLNodeType.VertexDescriptor.nodeParser(node, key: k, options: options)!
//            }.inObjectScope(.None) // always return a new instance of the closure
//
//        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.Camera.rawValue) { (r, k: String, node: XMLElement, options: [String:Any]) in
//            return SpectraXMLNodeType.Camera.nodeParser(node, key: k, options: options)!
//            }.inObjectScope(.None) // always return a new instance of the closure
//
//        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.StereoscopicCamera.rawValue) { (r, k: String, node: XMLElement, options: [String:Any]) in
//            return SpectraXMLNodeType.StereoscopicCamera.nodeParser(node, key: k, options: options)!
//            }.inObjectScope(.None) // always return a new instance of the closure
//
//        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.PhysicalLens.rawValue) { (r, k: String, node: XMLElement, options: [String:Any]) in
//            return SpectraXMLNodeType.PhysicalLens.nodeParser(node, key: k, options: options)!
//            }.inObjectScope(.None) // always return a new instance of the closure
//
//        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.PhysicalImagingSurface.rawValue) { (r, k: String, node: XMLElement, options: [String:Any]) in
//            return SpectraXMLNodeType.PhysicalImagingSurface.nodeParser(node, key: k, options: options)!
//            }.inObjectScope(.None) // always return a new instance of the closure
//
//        //        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.World.rawValue) { (r, k: String, node: XMLElement, options: [String: Any]) in
//        //            return SpectraXMLNodeType.World.nodeParser(node, key: k, options: options)!
//        //            }.inObjectScope(.None) // always return a new instance of the closure
//
//        return parser
//    }
//
//    public func parse(container: Container, options: [String: Any] = [:]) {
//        for child in xml!.root!.children {
//            let (tag, key) = (child.tag!, child.attributes["key"])
//
//            if let nodeType = SpectraXMLNodeType(rawValue: tag) {
//                // let nodeParser = self.parser.resolve(SpectraXMLNodeParser.self, arguments: (tag, key, child, options))!
//                // let nodeKlass = nodeType.nodeFinalType(parser)!.dynamicType
//                // let result = nodeParser(container: container, node: child, key: key, options: options)
//
//                // let resultKlass = SpectraXMLNodeType(rawValue: tag)!.nodeFinalType(parser)!
//                // container.register(result.dynamicType, name: tag) { _ in
//                //      return result
//                //  }
//
//                // TODO: move this out of parse() - it was in SpectraXMLNodeType,
//                // - but i can't return an AnyClass and then parse it later
//                switch nodeType {
//                case .VertexAttribute:
//                    let vertexAttr = SpectraXMLVertexAttributeNode().parse(container, elem: child, options: options)
//                    container.register(MDLVertexAttribute.self, name: key!) { _ in
//                        return (vertexAttr.copy() as! MDLVertexAttribute)
//                        }.inObjectScope(.None)
//                case .VertexDescriptor:
//                    let vertexDesc = SpectraXMLVertexDescriptorNode().parse(container, elem: child, options: options)
//                    container.register(MDLVertexDescriptor.self, name: key!)  { _ in
//                        return MDLVertexDescriptor(vertexDescriptor: vertexDesc)
//                        }.inObjectScope(.None)
//                case .BufferAllocator:
//                    let allocator = SpectraXMLBufferAllocatorNode().parse(container, elem: child, options: options)
//                    container.register(MDLMeshBufferAllocator.self, name: key!) { _ in
//                        return allocator
//                        }.inObjectScope(.None)
//                case .Asset:
//                    let assetNode = AssetNode()
//                    assetNode.parseXML(container, elem: child, options: options)
//                    let asset = assetNode.generate(container)
//                    container.register(MDLAsset.self, name: key!) { _ in
//                        return asset.copy() as! MDLAsset
//                        }.inObjectScope(.None)
//                case .Object:
//                    let obj = SpectraXMLObjectNode().parse(container, elem: child, options: options)
//                    container.register(MDLObject.self, name: key!) { _ in
//                        return SpectraXMLObjectNode.copy(obj)
//                        }.inObjectScope(.None)
//                case .Mesh:
//                    let meshNode = MeshNode()
//                    meshNode.parseXML(container, elem: child, options: options)
//                    let meshGen = container.resolve(MeshGenerator.self, name: meshNode.generator)!
//                    let mesh = meshGen.generate(container, args: meshNode.args)
//                    container.register(MDLMesh.self, name: key!) { _ in
//                        // TODO: don't copy meshes?
//                        return mesh
//                        }.inObjectScope(.None)
//                case .MeshGenerator:
//                    let meshGenNode = MeshGeneratorNode()
//                    meshGenNode.parseXML(container, elem: child, options: options)
//                    let meshGen = meshGenNode.createGenerator(container, options: options)
//                    container.register(MeshGenerator.self, name: key!) { _ in
//                        return meshGen.copy(container)
//                        }.inObjectScope(.None)
//                case .Camera:
//                    let camera = SpectraXMLCameraNode().parse(container, elem: child, options: options)
//                    container.register(MDLCamera.self, name: key!) { _ in
//                        return SpectraXMLCameraNode.copy(camera)
//                        }.inObjectScope(.None)
//                case .StereoscopicCamera:
//                    let stereoCam = SpectraXMLStereoscopicCameraNode().parse(container, elem: child, options: options)
//                    container.register(MDLStereoscopicCamera.self, name: key!) { _ in
//                        return SpectraXMLStereoscopicCameraNode.copy(stereoCam)
//                        }.inObjectScope(.None)
//                case .PhysicalLens:
//                    let lensNode = PhysicalLensNode()
//                    lensNode.parseXML(container, elem: child, options: options)
//                    container.register(PhysicalLensNode.self, name: key!) { _ in
//                        return (lensNode.copy() as! PhysicalLensNode)
//                        }.inObjectScope(.None)
//                case .PhysicalImagingSurface:
//                    let imagingSurfaceNode = PhysicalImagingSurfaceNode()
//                    imagingSurfaceNode.parseXML(container, elem: child, options: options)
//                    container.register(PhysicalImagingSurfaceNode.self, name: key!) { _ in
//                        return (imagingSurfaceNode.copy() as! PhysicalImagingSurfaceNode)
//                        }.inObjectScope(.None)
//                case .Transform:
//                    let transform = SpectraXMLTransformNode().parse(container, elem: child, options: options)
//                    container.register(MDLTransform.self, name: key!) { _ in
//                        return SpectraXMLTransformNode.copy(transform)
//                    }.inObjectScope(.None)
//                case .Texture:
//                    let textureNode = TextureNode()
//                    textureNode.parseXML(container, elem: child, options: options)
//                    let textureGen = container.resolve(TextureGenerator.self, name: textureNode.generator)!
//                    let texture = textureGen.generate(container, args: textureNode.args)
//                    container.register(MDLTexture.self, name: key!) { _ in
//                        // don't copy texture
//                        return texture
//                    }
//                case .TextureGenerator:
//                    let texGenNode = TextureGeneratorNode()
//                    texGenNode.parseXML(container, elem: child, options: options)
//                    let texGen = texGenNode.createGenerator(container, options: options)
//                    container.register(TextureGenerator.self, name: key!) { _ in
//                        return texGen.copy(container)
//                        }.inObjectScope(.None)
//                case .TextureFilter:
//                    let filterNode = TextureFilterNode()
//                    filterNode.parseXML(container, elem: child, options: options)
//                    let filter = filterNode.generate(container, options: options)
//                    container.register(MDLTextureFilter.self, name: key!) { _ in
//                        return TextureFilterNode.copy(filter)
//                    }
//                default: break
//                }
//
//                //TODO: use .dynamicType for meta type at run time
//                // - nvm, "auto-injection" feature won't be in swinject until 2.0.0
//
//                // TODO: use options to set ObjectScope (default to .Container?)
//
//                // TODO: recursively resolve non-final types in tuple:
//                // - i.e. if some monad returns instead of concrete value,
//                //   - then try to resolve the monad (should metadata also be returned?)
//                //   - this may be a feature to implement down the road
//                // - it can be resolved by returning either a tuple with metadata
//                //   - or a hash of [String: Any], but the tuple is superior
//                //   - tuple: (SpectraMonadType, [String: Any])
//                // - but i still would have to perform type resolution on the [String: Any]
//                //   - if the tupal is to be useful and dynamic
//
//            }
//        }
//    }