//
//  SpectraXML.swift
//
//
//  Created by David Conner on 2/22/16.
//
//

import Foundation
import Fuzi
import Swinject
import MetalKit
import ModelIO

// PLZ NOTE: i promise I'm not pursuing this terrible XML parsing design for
//   lack of an alternative design.  Here's at least 3 issues I'm balancing:
// (1) minimize stored references to unnecessary data
//   - e.g. don't store XMLElement objects or accidentally retain stuff with closure definitions
// (2) avoid extending ModelIO & Metal base class (to add copy(), parseXML() and whatnot)
// (3) and avoid mirroring the ModelIO & Metal object's api's - which already mirror each other to some degree!
//   - simply mirroring the ModelIO & Metal api's by introducing new classes
//     where everything is mostly named the same just adds confusion
//   - although it makes it easier to add parseJSON(), parsePlist() & copy()
//
// that said, i'm sticking to this shit design because it's all probably going to change completely anyways,
//   so why fret over minor changes when a major change would make them all irrelevant?
//
// I do wish I knew of a meta way to do this:
// - something like Ruby's obj.responds_to(:"foo=") && obj.send(":foo", "bar")

//public typealias SpectraXMLNodeParser = ((container: Container, node: XMLElement, key: String?, options: [String: Any]) -> AnyObject)

// (SpectraXMLNodeType)
//    // TODO: reimplement nodeParser() once auto-injection is available in Swinject
//    // - until then, I really can't resolve the type
//    public func nodeParser(node: XMLElement, key: String, options: [String: Any] = [:]) -> SpectraXMLNodeParser? {
//        
//        //NOTE: nodeParser can't be used until either
//        // - (1) Swinject supports auto-injection
//        // - (2) I can resolve the reflection issues with resolving a swinject container of arbitrary type
//        //    - can i do this with func generics: func nodeParser<NodeType>(...) -> SpectraXMLNodeParser<NodeType>?
//        
//        switch self {
//        case .VertexAttribute: return {(container, node, key, options) in
//            let vertexAttr = SpectraXMLVertexAttributeNode().parse(container, elem: node, options: options)
//            return vertexAttr
//            }
//        case .VertexDescriptor:
//            return {(container, node, key, options) in
//                let vertexDesc = SpectraXMLVertexDescriptorNode().parse(container, elem: node, options: options)
//                return vertexDesc
//            }
//        case .World:
//            return {(container, node, key, options) in
//                return "a world"
//            }
//        case .Camera:
//            return {(container, node, key, options) in
//                let cam = SpectraXMLCameraNode().parse(container, elem: node, options: options)
//                return cam
//            }
//        case .MeshGenerator:
//            return {(container, node, key, options) in
//                return "a mesh generator"
//            }
//            
//        default: return nil
//        }
//    }
//    
//    public func nodeFinalType(parser: Container) -> AnyClass? {
//        switch self {
//        case .VertexAttribute: return MDLVertexAttribute.self
//        case .VertexDescriptor: return MDLVertexDescriptor.self
//        default: return nil // custom types must be resolved separately
//        }
//    }
//}
//


//public class SpectraXMLBufferAllocatorNode: SpectraXMLNode {
//    public typealias NodeType = MDLMeshBufferAllocator
//    
//    public func parse(container: Container, elem: XMLElement, options: [String: Any] =
//[:]) -> NodeType {
//        // TODO: add a MeshBufferAllocatorGenerator protocol
//        // - with a generate function (also take an args: [String: GeneratorArg] = [:])
//        // - instead of fetching from the container's MDLMeshBufferAllocator.self
//        //   - we fetch from the MeshBufferAllocatorGenerator.self registration
//        
//        let alloc8: MDLMeshBufferAllocator?
//        
//        if let type = elem.attributes["type"] {
//            alloc8 = container.resolve(MDLMeshBufferAllocator.self, name: type)
//        } else {
//            // TODO: add available mtl devices to a root container
//            // - it will build, but it won't work
//            let mtlDevice = container.resolve(MTLDevice.self, name: "default")!
//            alloc8 = MTKMeshBufferAllocator(device: mtlDevice)
//        }
//        
//        // TODO: how to assign other attributes of a buffer allocator?
//        // - especially when users can define their own properties
//        //   - mimic the mesh generation setup, so users can define args
//        
//        return alloc8!
//    }
//    
//    // TODO: copy?  honestly, can a memory management object like this be copied?
//    // - or at least efficiently copied in some meaningful way?  i think not
//    // - no copies for you!
//    //   - instead create a new registration and manage instances
//    // - registrations for MDLMeshBufferAllocator.self manage instances
//    // - and registration for MeshBufferAllocatorGenerators manage generator instances
//    //   - and pop out new buffer allocators
//    
//}

//// TODO: store sets of arguments in <generator-arg-set> tags?
//// - make these monadic? so that values can be replaced?
//// - make these composable?


//public class SpectraXMLObjectNode: SpectraXMLNode {
//    public typealias NodeType = MDLObject
//    
//    public func parse(container: Container, elem: XMLElement, options: [String : Any] = [:]) -> NodeType {
//        var object = MDLObject()
//        
//        if let name = elem.attributes["name"] {
//            object.name = name
//        }
//        
//        let transformSelector = SpectraXMLNodeType.Transform.rawValue
//        if let transformTag = elem.firstChild(tag: transformSelector) {
//            if let ref = transformTag.attributes["ref"] {
//                let transform = container.resolve(MDLTransform.self, name: ref)!
//                object.transform = transform
//            } else {
//                let transform = SpectraXMLTransformNode().parse(container, elem: transformTag, options: options)
//                if let transformKey = transformTag.attributes["key"] {
//                    container.register(MDLTransform.self, name: transformKey) { _ in
//                        return SpectraXMLTransformNode.copy(transform)
//                    }
//                }
//                object.transform = transform
//            }
//        }
//        
//        // NOTE: nodes should be parsed in order (searching for each type won't work)
//        for (idx, el) in elem.children.enumerate() {
//            let objKey = el.attributes["key"]
//            let objRef = el.attributes["ref"]
//            
//            if let nodeType = SpectraXMLNodeType(rawValue: el.tag!) {
//                switch nodeType {
//                case .Object:
//                    if let ref = objRef {
//                        let obj = container.resolve(MDLObject.self, name: ref)!
//                        object.addChild(obj)
//                    } else {
//                        let obj = SpectraXMLObjectNode().parse(container, elem: el, options: options)
//                        if let key = objKey {
//                            container.register(MDLObject.self, name: key) { _ in
//                                return SpectraXMLObjectNode.copy(obj)
//                            }
//                        }
//                        object.addChild(obj)
//                    }
//                    
//                // set parent??
//                case .Camera:
//                    if let ref = objRef {
//                        let cam = container.resolve(MDLCamera.self, name: ref)!
//                        object.addChild(cam)
//                    } else {
//                        let cam = SpectraXMLCameraNode().parse(container, elem: el, options: options)
//                        if let key = objKey {
//                            container.register(MDLCamera.self, name: key) { _ in
//                                return SpectraXMLCameraNode.copy(cam)
//                            }
//                        }
//                    }
//                    
//                case .StereoscopicCamera:
//                    if let ref = objRef {
//                        let cam = container.resolve(MDLStereoscopicCamera.self, name: ref)!
//                        object.addChild(cam)
//                    } else {
//                        let cam = SpectraXMLStereoscopicCameraNode().parse(container, elem: el, options: options)
//                        if let key = objKey {
//                            container.register(MDLStereoscopicCamera.self, name: key) { _ in
//                                return SpectraXMLStereoscopicCameraNode.copy(cam)
//                            }
//                        }
//                    }
//                    
//                case .Light: break
//                case .Mesh: break
//                default: break
//                }
//                
//            } else {
//                // parse other nodes (custom nodes, etc)
//            }
//        }
//        
//        return object
//    }
//    
//    public static func copy(object: NodeType) -> NodeType {
//        let cp = MDLObject()
//
//        cp.name = object.name.copy() as! String
//        
//        if let transform = object.transform {
//            if transform is MDLTransform {
//                cp.transform = SpectraXMLTransformNode.copy(object.transform! as! MDLTransform)
//            } else {
//                // TODO: fix the copy by reference
//                cp.transform = object.transform
//            }
//        }
//        
//        if let objContainer = object.componentConformingToProtocol(MDLObjectContainerComponent.self) {
//            // strange that an object with no children returns nil,
//            // - yet the compiler thinks this is impossible
//            
//            if object.children.objects.count > 0 {
//                for obj in object.children.objects {
//                    switch obj {
//                    case is MDLCamera:
//                        cp.addChild(SpectraXMLCameraNode.copy(obj as! MDLCamera))
//                    case is MDLStereoscopicCamera:
//                        cp.addChild(SpectraXMLStereoscopicCameraNode.copy(obj as! MDLStereoscopicCamera))
//                    case is MDLLight: break
//                    case is MDLMesh: break
//                    default:
//                        //TODO: account for case when obj is subclass of MDLObject, but not MDLObject
//                        // - can't use (obj is MDLObject) or !(obj is MDLObject) bc that's always true/false
//                        cp.addChild(SpectraXMLObjectNode.copy(obj))
//                    }
//                }
//            }
//        }
//        
//        return cp
//    }
//}
//
////============================================================
//// TODO: decide how to handle inheritance
//// - use separate node classes for each instance
////   - this would be appropriate for some, like MDLCamera & Stereoscopic (except phys lens & phys imaging)
////   - but gets cumbersome for other classes, like MDLTexture, etc.
////   - and isn't extensible
//// - there's also the mesh-generator pattern from the original SceneGraphXML
////   - this draws from a map of monads passed in and executes the one for a specific type, if found
//



//// TODO: public class SpectraXMLLightNode: SpectraXMLNode {
//// TODO: public class SpectraXML ... etc
//// TODO: public class SpectraXMLMaterialNode: SpectraXMLNode {
//// TODO: public class SpectraXMLMaterialPropertyNode: SpectraXMLNode {
//// TODO: public class SpectraXMLScatteringFunctionNode: SpectraXMLNode {
//// TODO: public class .. voxel array?  maybe a generator
//// TODO: public class .. voxel morphism (morphology in 3D)
