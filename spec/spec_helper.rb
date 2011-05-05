require 'cheetah'

CM_SUB_ID           = "2087039029"           # the test mailing list id
CM_WHITELIST_FILTER = /@buywithme\.com$/     # if set, emails will only be sent to addresses which match this pattern
CM_ENABLE_TRACKING  = false                  # determines whether cheetahmail will track the sending of emails for statistical purposes. this should be disabled outside of production 
CM_MESSENGER        = Cheetah::NullMessenger # the class used for sending api requests to cheetahmail.
