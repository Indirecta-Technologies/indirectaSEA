local random = Random.new();

return function(secret) 


    if secret then secret = string.split(secret, ":") else
        secret = {
            random:NextNumber(0, 63),
            random:NextNumber(0, 127),
            random:NextNumber(0, 17592186044415),
            random:NextNumber(0, 255);
        }
    end

    return require(script.sea).new(secret);
end