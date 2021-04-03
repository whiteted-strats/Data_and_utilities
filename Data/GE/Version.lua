-- Set a global for everyone to determine their addresses off of

memory.usememorydomain("ROM")
__GE_VERSION__ = string.char(memory.readbyte(0x3E))  -- E,J,P
if __GE_VERSION__ == "E" then
    __GE_VERSION__ = "U"
end
-- Now U,J,P :)

memory.usememorydomain("RDRAM") -- switch back