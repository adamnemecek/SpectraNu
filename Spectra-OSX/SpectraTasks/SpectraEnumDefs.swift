//
//  SpectraEnumDefs.swift
//  SpectraOSX
//
//  Created by David Conner on 2/22/16.
//  Copyright © 2016 Spectra. All rights reserved.
//

import Foundation
import ModelIO

class SpectraEnumDefs {

    static let mdlVertexFormat = [
        "Invalid": MDLVertexFormat.Invalid.rawValue,
        "PackedBit": MDLVertexFormat.PackedBit.rawValue,
        "UCharBits": MDLVertexFormat.UCharBits.rawValue,
        "CharBits": MDLVertexFormat.CharBits.rawValue,
        "UCharNormalizedBits": MDLVertexFormat.UCharNormalizedBits.rawValue,
        "CharNormalizedBits": MDLVertexFormat.CharNormalizedBits.rawValue,
        "UShortBits": MDLVertexFormat.UShortBits.rawValue,
        "ShortBits": MDLVertexFormat.ShortBits.rawValue,
        "UShortNormalizedBits": MDLVertexFormat.UShortNormalizedBits.rawValue,
        "ShortNormalizedBits": MDLVertexFormat.ShortNormalizedBits.rawValue,
        "UIntBits": MDLVertexFormat.UIntBits.rawValue,
        "IntBits": MDLVertexFormat.IntBits.rawValue,
        "HalfBits": MDLVertexFormat.HalfBits.rawValue,
        "FloatBits": MDLVertexFormat.FloatBits.rawValue,
        "UChar": MDLVertexFormat.UChar.rawValue,
        "UChar2": MDLVertexFormat.UChar2.rawValue,
        "UChar3": MDLVertexFormat.UChar3.rawValue,
        "UChar4": MDLVertexFormat.UChar4.rawValue,
        "Char": MDLVertexFormat.Char.rawValue,
        "Char2": MDLVertexFormat.Char2.rawValue,
        "Char3": MDLVertexFormat.Char3.rawValue,
        "Char4": MDLVertexFormat.Char4.rawValue,
        "UCharNormalized": MDLVertexFormat.UCharNormalized.rawValue,
        "UChar2Normalized": MDLVertexFormat.UChar2Normalized.rawValue,
        "UChar3Normalized": MDLVertexFormat.UChar3Normalized.rawValue,
        "UChar4Normalized": MDLVertexFormat.UChar4Normalized.rawValue,
        "CharNormalized": MDLVertexFormat.CharNormalized.rawValue,
        "Char2Normalized": MDLVertexFormat.Char2Normalized.rawValue,
        "Char3Normalized": MDLVertexFormat.Char3Normalized.rawValue,
        "Char4Normalized": MDLVertexFormat.Char4Normalized.rawValue,
        "UShort": MDLVertexFormat.UShort.rawValue,
        "UShort2": MDLVertexFormat.UShort2.rawValue,
        "UShort3": MDLVertexFormat.UShort3.rawValue,
        "UShort4": MDLVertexFormat.UShort4.rawValue,
        "Short": MDLVertexFormat.Short.rawValue,
        "Short2": MDLVertexFormat.Short2.rawValue,
        "Short3": MDLVertexFormat.Short3.rawValue,
        "Short4": MDLVertexFormat.Short4.rawValue,
        "UShortNormalized": MDLVertexFormat.UShortNormalized.rawValue,
        "UShort2Normalized": MDLVertexFormat.UShort2Normalized.rawValue,
        "UShort3Normalized": MDLVertexFormat.UShort3Normalized.rawValue,
        "UShort4Normalized": MDLVertexFormat.UShort4Normalized.rawValue,
        "ShortNormalized": MDLVertexFormat.ShortNormalized.rawValue,
        "Short2Normalized": MDLVertexFormat.Short2Normalized.rawValue,
        "Short3Normalized": MDLVertexFormat.Short3Normalized.rawValue,
        "Short4Normalized": MDLVertexFormat.Short4Normalized.rawValue,
        "UInt": MDLVertexFormat.UInt.rawValue,
        "UInt2": MDLVertexFormat.UInt2.rawValue,
        "UInt3": MDLVertexFormat.UInt3.rawValue,
        "UInt4": MDLVertexFormat.UInt4.rawValue,
        "Int": MDLVertexFormat.Int.rawValue,
        "Int2": MDLVertexFormat.Int2.rawValue,
        "Int3": MDLVertexFormat.Int3.rawValue,
        "Int4": MDLVertexFormat.Int4.rawValue,
        "Half": MDLVertexFormat.Half.rawValue,
        "Half2": MDLVertexFormat.Half2.rawValue,
        "Half3": MDLVertexFormat.Half3.rawValue,
        "Half4": MDLVertexFormat.Half4.rawValue,
        "Float": MDLVertexFormat.Float.rawValue,
        "Float2": MDLVertexFormat.Float2.rawValue,
        "Float3": MDLVertexFormat.Float3.rawValue,
        "Float4": MDLVertexFormat.Float4.rawValue,
        "Int1010102Normalized": MDLVertexFormat.Int1010102Normalized.rawValue,
        "UInt1010102Normalized": MDLVertexFormat.UInt1010102Normalized.rawValue]
    
    static let mdlMaterialSemantic = [
        "BaseColor": MDLMaterialSemantic.BaseColor.rawValue,
        "Subsurface": MDLMaterialSemantic.Subsurface.rawValue,
        "Metallic": MDLMaterialSemantic.Metallic.rawValue,
        "Specular": MDLMaterialSemantic.Specular.rawValue,
        "SpecularExponent": MDLMaterialSemantic.SpecularExponent.rawValue,
        "SpecularTint": MDLMaterialSemantic.SpecularTint.rawValue,
        "Roughness": MDLMaterialSemantic.Roughness.rawValue,
        "Anisotropic": MDLMaterialSemantic.Anisotropic.rawValue,
        "AnisotropicRotation": MDLMaterialSemantic.AnisotropicRotation.rawValue,
        "Sheen": MDLMaterialSemantic.Sheen.rawValue,
        "SheenTint": MDLMaterialSemantic.SheenTint.rawValue,
        "Clearcoat": MDLMaterialSemantic.Clearcoat.rawValue,
        "ClearcoatGloss": MDLMaterialSemantic.ClearcoatGloss.rawValue,
        "Emission": MDLMaterialSemantic.Emission.rawValue,
        "Bump": MDLMaterialSemantic.Bump.rawValue,
        "Opacity": MDLMaterialSemantic.Opacity.rawValue,
        "InterfaceIndexOfRefraction": MDLMaterialSemantic.InterfaceIndexOfRefraction.rawValue,
        "MaterialIndexOfRefraction": MDLMaterialSemantic.MaterialIndexOfRefraction.rawValue,
        "ObjectSpaceNormal": MDLMaterialSemantic.ObjectSpaceNormal.rawValue,
        "TangentSpaceNormal": MDLMaterialSemantic.TangentSpaceNormal.rawValue,
        "Displacement": MDLMaterialSemantic.Displacement.rawValue,
        "DisplacementScale": MDLMaterialSemantic.DisplacementScale.rawValue,
        "AmbientOcclusion": MDLMaterialSemantic.AmbientOcclusion.rawValue,
        "AmbientOcclusionScale": MDLMaterialSemantic.AmbientOcclusionScale.rawValue,
        "None": MDLMaterialSemantic.None.rawValue,
        "UserDefined": MDLMaterialSemantic.UserDefined.rawValue
    ]
    
    static let mdlMaterialPropertyType = [
        "None": MDLMaterialPropertyType.None.rawValue,
        "String": MDLMaterialPropertyType.String.rawValue,
        "URL": MDLMaterialPropertyType.URL.rawValue,
        "Texture": MDLMaterialPropertyType.Texture.rawValue,
        "Color": MDLMaterialPropertyType.Color.rawValue,
        "Float": MDLMaterialPropertyType.Float.rawValue,
        "Float2": MDLMaterialPropertyType.Float2.rawValue,
        "Float3": MDLMaterialPropertyType.Float3.rawValue,
        "Float4": MDLMaterialPropertyType.Float4.rawValue,
        "Matrix44": MDLMaterialPropertyType.Matrix44.rawValue
    ]
    
    static let mdlMaterialTextureWrapMode = [
        "Clamp": MDLMaterialTextureWrapMode.Clamp.rawValue,
        "Repeat": MDLMaterialTextureWrapMode.Repeat.rawValue,
        "Mirror": MDLMaterialTextureWrapMode.Mirror.rawValue
    ]
    
    static let mdlMaterialTextureFilterMode = [
        "Nearest": MDLMaterialTextureFilterMode.Nearest.rawValue,
        "Linear": MDLMaterialTextureFilterMode.Linear.rawValue
    ]
    
    static let mdlMaterialMipMapFilterMode = [
        "Nearest": MDLMaterialMipMapFilterMode.Nearest.rawValue,
        "Linear": MDLMaterialMipMapFilterMode.Linear.rawValue
    ]
    
}