class CheetahException < Exception
end

class CheetahAuthorizationException < CheetahException
end

class CheetahTemporaryException < CheetahException
end

class CheetahPermanentException < CheetahException
end
