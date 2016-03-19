//
//  MetalXSD
//
//
//  Created by David Conner on 10/12/15.
//
//

import Foundation
import Fuzi
import Swinject

public enum MetalNodeType: String {
    case VertexFunction = "vertex-function"
    case FragmentFunction = "fragment-function"
    case ComputeFunction = "compute-function"
    case ClearColor = "clear-color"
    case VertexDescriptor = "vertex-descriptor"
    case VertexAttributeDescriptor = "vertex-attribute-descriptor"
    case VertexBufferLayoutDescriptor = "vertex-buffer-layout-descriptor"
    case TextureDescriptor = "texture-descriptor"
    case SamplerDescriptor = "sampler-descriptor"
    case StencilDescriptor = "stencil-descriptor"
    case DepthStencilDescriptor = "depth-stencil-descriptor"
    case RenderPipelineDescriptor = "render-pipeline-descriptor"
    case ComputePipelineDescriptor = "compute-pipeline-descriptor"
    case RenderPassColorAttachmentDescriptor = "render-pass-color-attachment-descriptor"
    case RenderPassDepthAttachmentDescriptor = "render-pass-depth-attachment-descriptor"
    case RenderPassStencilAttachmentDescriptor = "render-pass-stencil-attachment-descriptor"
    case RenderPassDescriptor = "render-pass-descriptor"
}

public typealias MetalNodeBuilder = ((containers: [String: Container], options: [String: Any]?)) -> (containers: [String: Container], options: [String: Any]?)
public typealias MetalRegBuilder = ((containers: [String: Container], options: [String: Any]?)) -> (containers: [String: Container], options: [String: Any]?)

// TODO: switch to format similar to SpectraXML 
// - maybe? these objects are all easily copyable
public protocol MetalNode {
    typealias NodeType
    func parse(container: Container, elem: XMLElement, options: [String: AnyObject]) -> NodeType
}

public class MetalParser {
    // NOTE: if device/library
    public var nodes: Container!
    
    public init(nodes: Container = Container()) {
        self.nodes = nodes
    }
    
    public init(parentContainer: Container) {
        self.nodes = Container(parent: parentContainer)
    }
    
    public func getMetalEnum(name: String, id: String) -> UInt {
        return nodes.resolve(MetalEnum.self, name: name)!.getValue(id)
    }
    
    public func getVertexFunction(id: String) -> MTLFunction {
        return nodes.resolve(MTLFunction.self, name: id)!
    }
    
    public func getFragmentFunction(id: String) -> MTLFunction {
        return nodes.resolve(MTLFunction.self, name: id)!
    }
    
    public func getComputeFunction(id: String) -> MTLFunction {
        return nodes.resolve(MTLFunction.self, name: id)!
    }
    
    public func getVertexDescriptor(id: String) -> MTLVertexDescriptor {
        return nodes.resolve(MTLVertexDescriptor.self, name: id)!
    }
    
    public func getTextureDescriptor(id: String) -> MTLTextureDescriptor {
        return nodes.resolve(MTLTextureDescriptor.self, name: id)!
    }
    
    public func getSamplerDescriptor(id: String) -> MTLSamplerDescriptor {
        return nodes.resolve(MTLSamplerDescriptor.self, name: id)!
    }
    
    public func getStencilDescriptor(id: String) -> MTLStencilDescriptor {
        return nodes.resolve(MTLStencilDescriptor.self, name: id)!
    }
    
    public func getDepthStencilDescriptor(id: String) -> MTLDepthStencilDescriptor {
        return nodes.resolve(MTLDepthStencilDescriptor.self, name: id)!
    }
    
    public func getColorAttachmentDescriptor(id: String) -> MTLRenderPipelineColorAttachmentDescriptor {
        return nodes.resolve(MTLRenderPipelineColorAttachmentDescriptor.self, name: id)!
    }
    
    public func getRenderPipelineDescriptor(id: String) -> MTLRenderPipelineDescriptor {
        return nodes.resolve(MTLRenderPipelineDescriptor.self, name: id)!
    }
    
    public func getClearColor(id: String) -> MTLClearColor {
        return nodes.resolve(MTLClearColor.self, name: id)!
    }
    
    public func getRenderPassColorAttachmentDescriptor(id: String) -> MTLRenderPassColorAttachmentDescriptor {
        return nodes.resolve(MTLRenderPassColorAttachmentDescriptor.self, name: id)!
    }
    
    public func getRenderPassDepthAttachmentDescriptor(id: String) -> MTLRenderPassDepthAttachmentDescriptor {
        return nodes.resolve(MTLRenderPassDepthAttachmentDescriptor.self, name: id)!
    }
    
    public func getRenderPassStencilAttachmentDescriptor(id: String) -> MTLRenderPassStencilAttachmentDescriptor {
        return nodes.resolve(MTLRenderPassStencilAttachmentDescriptor.self, name: id)!
    }
    
    public func getRenderPassDescriptor(id: String) -> MTLRenderPassDescriptor {
        return nodes.resolve(MTLRenderPassDescriptor.self, name: id)!
    }
    
    public func getComputePipelineDescriptor(id: String) -> MTLComputePipelineDescriptor {
        return nodes.resolve(MTLComputePipelineDescriptor.self, name: id)!
    }
    
    // TODO: parse XML
    
    public static func initMetalEnums(container: Container) -> Container {
        let xmlData = MetalXSD.readXSD("MetalEnums")
        let xsd = MetalXSD(data: xmlData)
        xsd.parseEnumTypes(container)
        return container
    }
    
    public static func initMetal(container: Container) -> Container {
        // TODO: decide whether or not to let the device persist for the lifetime of the top-level container
        // - many classes require the device (and for some, i think object id matters, like for MTLLibrary)
        let dev = MTLCreateSystemDefaultDevice()!
        let lib = dev.newDefaultLibrary()!
        container.register(MTLDevice.self, name: "default") { _ in
            return dev
            }.inObjectScope(.None)
        
        container.register(MTLLibrary.self, name: "default") { _ in
            return lib
            }.inObjectScope(.None)
        
        return container
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

public class MetalEnum {
    var name: String
    var values: [String: UInt] = [:] // private?
    
    public init(elem: XMLElement) {
        values = [:]
        name = elem.attributes["name"]!
        let valuesSelector = "xs:restriction > xs:enumeration"
        for child in elem.css(valuesSelector) {
            let val = child.attributes["id"]!
            let key = child.attributes["value"]!
            self.values[key] = UInt(val)
        }
    }
    
    public func getValue(id: String) -> UInt {
        return values[id]!
    }
    
    //    public func convertToEnum(key: String, val: Int) -> AnyObject {
    //        switch key {
    //        case "mtlStorageAction": return MTLStorageMode(rawValue: UInt(val))!
    //        default: val
    //        }
    //    }
}

public class MetalXSD {
    public var xsd: XMLDocument?
    var enumTypes: [String: MetalEnum] = [:]
    
    public init(data: NSData) {
        do {
            xsd = try XMLDocument(data: data)
        } catch let err as XMLError {
            switch err {
            case .ParserFailure, .InvalidData: print(err)
            case .LibXMLError(let code, let message): print("libxml error code: \(code), message: \(message)")
            default: break
            }
        } catch let err {
            print("error: \(err)")
        }
    }
    
    public class func readXSD(filename: String) -> NSData {
        let bundle = NSBundle(forClass: MetalXSD.self)
        let path = bundle.pathForResource(filename, ofType: "xsd")
        let data = NSData(contentsOfFile: path!)
        return data!
    }
    
    public func parseEnumTypes(container: Container) {
        let enumTypesSelector = "xs:simpleType[mtl-enum=true]"
        
        for enumChild in xsd!.css(enumTypesSelector) {
            let enumType = MetalEnum(elem: enumChild)
            container.register(MetalEnum.self, name: enumType.name) { _ in
                return enumType
            }
        }
    }
}
