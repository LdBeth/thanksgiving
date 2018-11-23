module Parse where

import Data.String.Utils (replace)

format :: (String -> String) -> String -> String
format f t =
  "(tts_text \"<SABLE>"
  ++ f (escape t)
  ++ "</SABLE>\" 'sable)"

escape :: String -> String
escape = replace "\"" "\\\""

say :: String -> String
say =  replace "[*]" " "

playSound :: String -> String
playSound x = "<AUDIO SRC=\"file://" ++ x ++ "\"/>"

letter :: String -> String
letter x = "<SAYAS MODE=\\\"literal\\\">" ++
           x ++ "</SAYAS>"
