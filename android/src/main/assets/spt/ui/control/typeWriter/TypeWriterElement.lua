local TypeWriterElement = class(unity.base)

ElementType = {
    TEXT = 1,
    IMAGE = 2,
    BYTESIMAGE = 3,
    GAMEOBJECT = 4,
}

function TypeWriterElement:ctor(elementType, component, attribute)
    self.elementType = elementType
    self.component = component
    self.attribute = attribute
end

function TypeWriterElement:GetElementType()
    return self.elementType
end

function TypeWriterElement:GetComponent()
    return self.component
end

function TypeWriterElement:GetAttribute()
    return self.attribute
end

return TypeWriterElement