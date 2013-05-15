class CheetahException < Exception
end

class CheetahSystemMaintenanceException < CheetahException
end

class CheetahMessagingException < CheetahException
end

class CheetahAuthorizationException < CheetahMessagingException
end

class CheetahTemporaryException < CheetahMessagingException
end

class CheetahPermanentException < CheetahMessagingException
end

class CheetahTooManyTriesException < CheetahMessagingException
end
