:Namespace Twitter

    (⎕IO ⎕ML ⎕WX)←1 1 3
   
      load_token←{ntie←'app.token'⎕NTIE 0
          token←⎕NREAD ntie,80,(⎕NSIZE ntie)
          ntie←⎕NUNTIE ntie
          token}
          
    save_token←{ntie←ncreate'app.token' ⋄ ⍵ ⎕NAPPEND ntie ⋄ ⎕NUNTIE ntie}


    auth←{('Authorization' ('Basic ',base64 ⎕UCS ⍺,':',⍵))}

      base64←{⎕IO ⎕ML←0 1             ⍝ Base64 encoding and decoding as used in MIME.
     
          chars←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
          bits←{,⍉(⍺⍴2)⊤⍵}                   ⍝ encode each element of ⍵ in ⍺ bits,
                                            ⍝   and catenate them all together
          part←{((⍴⍵)⍴⍺↑1)⊂⍵}                ⍝ partition ⍵ into chunks of length ⍺
     
          0=2|⎕DR ⍵:2∘⊥∘(8∘↑)¨8 part{(-8|⍴⍵)↓⍵}6 bits{(⍵≠64)/⍵}chars⍳⍵
                                            ⍝ decode a string into octets
     
          four←{                             ⍝ use 4 characters to encode either
              8=⍴⍵:'=='∇ ⍵,0 0 0 0           ⍝   1,
              16=⍴⍵:'='∇ ⍵,0 0               ⍝   2
              chars[2∘⊥¨6 part ⍵],⍺          ⍝   or 3 octets of input
          }
          cats←⊃∘(,/)∘((⊂'')∘,)              ⍝ catenate zero or more strings
          cats''∘four¨24 part 8 bits ⍵
      }
      
    ∇ r←key get_token secret
      headers←((key auth secret)('Accept-Encoding' 'gzip'))
      postdata←⎕NS''
      postdata.(grant_type)←'client_credentials'
      r←#.Samples.HTTPReq'https://api.twitter.com/oauth2/token'postdata headers
    ∇

    :Class WgetRequest
        :Field Public Url
        :Field Public post_data
        ∇ request url
          :Implements Constructor
          :Access Public
          Url←url
          headers←''
          post_data=''
          query←''
        ∇
        :Field Public headers
        :Field Public query 
        ∇ r←prefix h
          r←⊃,/(⊂' --header="'),¨h,¨'"'
        ∇
        ∇ r←add_post_data
          r←(×⍴post_data)/' --post-data= "',post_data,'"'
        ∇
        ∇ r←form
          :Access public
          r←'wget -qO-',(prefix headers),' ',Url,(×⍴query)/'?',query
        ∇
    :EndClass

    ∇ ntie←ncreate file      ⍝ create empty native file
      :Trap 22                 ⍝ Trap file name error
          ntie←file ⎕NCREATE 0 ⍝ Try to create file
      :Else
          ntie←file ⎕NTIE 0
          file ⎕NERASE ntie
          file ⎕NCREATE ntie
      :EndTrap
    ∇
:EndNamespace 
