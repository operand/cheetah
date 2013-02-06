Sorry for not much documentation. I have to work on that...

But basically you create a Cheetah instance like so:


```ruby
    cheetah = Cheetah::Cheetah.new({
      :host             => 'ebm.cheetahmail.com',
      :username         => 'foo_api_user',
      :password         => '12345',
      :aid              => '67890',                  # the 'affiliate id'
      :whitelist_filter => //,                       # if set, emails will only be sent to addresses which match this pattern
      :enable_send_not_deployed   => true,           # if true, non-deployed emails can be set (default is false)
      :messenger        => Cheetah::ResqueMessenger
    })
```

,and then there are three methods you need to know about:


```ruby
    cheetah.send_email(
      eid,    # cheetahmail's EID for the event triggered email
      email,
      params, # a hash of parameters used to populate any dynamic fields in the email template
    )
    
    cheetah.mailing_list_update(
      email,
      params # a hash of parameters to populate the mailing list fields with
    )
    
    cheetah.mailing_list_email_change(
      oldemail,
      newemail
    )
```

Sending emails using the Cheetah mail transactional API. The event based message API does not support attachments. If your messages requires an attachments you will need to use the transactional API.

```ruby
    require 'cheetah'

    cheetah = Cheetah::TransactionalCheetah.new({messenger: Cheetah::SynchronousTransactionalMessenger})
    cheetah.send_email(67838, 'test@example.com', {FNAME: 'James', :systemmail_attachment_1 =>  File.new('attachment.pdf')})
```

To send messages asynchronously using the Cheetah mail transactional API use the *ResqueTransactionalMessenger*

```ruby
    cheetah = Cheetah::TransactionalCheetah.new({messenger: Cheetah::ResqueTransactionalMessenger})
```