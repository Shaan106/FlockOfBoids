-- Table print
function table.print ( t ) 
    local print_r_cache={}
    local str = ""
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
          --  str =  str .. indent.."*"..tostring(t)
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        str = str .. indent.."["..pos.."] => "..tostring(t).." {"
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                        str = str .. indent..string.rep(" ",string.len(pos)+6).."}"
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                       -- str = str .. indent.."["..pos..'] => "'..val..'"'
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                      --  str = str .. indent.."["..pos.."] => "..tostring(val)
                    end
                end
            else
                print(indent..tostring(t))
                --str = str .. indent..tostring(t)
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        str = str .. tostring(t).." {"
        sub_print_r(t,"  ")
        print("}")
        str = str .. "}"
    else
        sub_print_r(t,"  ")
    end

    return str
end
