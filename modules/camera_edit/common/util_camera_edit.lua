local UtilCameraEdit = T(Lib, "UtilCameraEdit")
local lfs = require("lfs")
local SLAXML = require "common.xml.slaxml"
function UtilCameraEdit:tb2xml(tbSrc)
    local xmlStr = ""
    for _, v in pairs(tbSrc) do
        xmlStr = xmlStr.."<CameraViewFrame x=\""..v.x.."\" y=\""..v.y.."\" z=\""..v.z.."\" yaw=\""..v.yaw.."\" pitch=\""..v.pitch.."\" smooth=\""..v.smooth.."\"/>\n"
    end
    return xmlStr
end
local fileSteam = nil
function UtilCameraEdit:tb2xmlAndSave(fileName,xmlSrc)
    if not fileName or not xmlSrc then
        return
    end
    if fileSteam then
        io.close(fileSteam)
        fileSteam = nil
    end
    local path = string.format("%sconfig/camera_path_xml/%s.xml", Root.Instance():getGamePath(), fileName)
    fileSteam = io.open(path,"w+")
    fileSteam:write(self:tb2xml(xmlSrc))
    io.close(fileSteam)
    fileSteam = nil
end

function UtilCameraEdit:xml2tb(xmlSrc)
    local element = {
        name = "",
        attribute = {}
    }
    local dataList = {}
    local parser = SLAXML:parser{
        startElement = function(name,nsURI,nsPrefix)
            element.name = name
        end,
        attribute    = function(name,value,nsURI,nsPrefix)
            element.attribute[name] = value
        end,
        closeElement = function(name,nsURI)
            local newBegin = true
            if element.name == "CameraViewFrame" then
                local x =  tonumber(element.attribute["x"])
                local y =  tonumber(element.attribute["y"])
                local z =  tonumber(element.attribute["z"])
                local yaw = tonumber(element.attribute["yaw"])
                local pitch = tonumber(element.attribute["pitch"])
                local smooth = tonumber(element.attribute["smooth"])
                -- self.attribute = element.attribute["distance"]
                --self.attribute = element.attribute["startTime"]
                local node = {}
                node.x = x
                node.y = y
                node.z = z
                node.yaw = yaw
                node.pitch = pitch
                node.smooth = smooth
                node.index = #dataList+1
                table.insert(dataList,node)
            end
            element = {
                name = "",
                attribute = {}
            }
        end,
    }
    parser:parse(xmlSrc:read('*all'),{stripWhitespace=true})
    io.close(xmlSrc)
    xmlSrc = nil
    return dataList
end