{-
This software is distributed in BSD-3 clause

I named it Thanksgiving because today is Thanksgiving, and tomorrow is Black
Friday.
-}
module Main where


import Data.Char (isSpace)
import Data.String.Utils (replace)
import System.IO (isEOF,Handle,stdout,hPutStrLn)
import Control.Monad (when)
import Data.ByteString.Char8 (pack, unpack)
import Control.Monad.IO.Class (MonadIO)
import Control.Monad.Catch (MonadMask)
import Network.Simple.TCP

--server :: ((Socket, SockAddr) -> IO Socket) -> IO Socket
server = connect "localhost" "1314"

process :: (Socket -> IO ()) -> IO ()
process p = server (\ (s,a) -> putStrLn ( "Connected to " ++ show a)
                         >> p s
                         >> return ())

toFestival ::  String -> Socket -> IO ()
toFestival x s = send s $ pack x
--toFestival = undefined


version :: String
version = "0.1.0.0"


data Context = Context
               { queue :: [String]
               , rate  :: Float
               , lMode :: Bool
               }

defaultArg = Context {queue = []
                     , rate = 1 -- they said this is reasonable
                     , lMode = False}

listener :: Socket -> Context -> IO ()
listener p s = isEOF >>=
  (\ x ->
      if x
      then return ()
      else getLine >>= parse >>= listener p)
  where parse "" = return s
        parse l = case commandWord l of
                    Nothing -> putStrLn "unable to parse"
                               >> return s
                    Just x  -> dispatch (p,s) x

type Command = String
type Argument = String

commandWord :: String -> Maybe (Command, Argument)
commandWord s = case break isSpace s of
                  ([],_) -> Nothing
                  (x,y) -> Just (x, f y)
  where f = f' . dropWhile  isSpace
        f' ('{':xs) = takeWhile (/= '}') xs
        f' s        = s

dispatch :: (Socket, Context) -> (Command, Argument) -> IO Context
dispatch (p,s) (c,a) =
  case c of
    "tts_set_speech_rate" ->   return s { rate  = read a / 225 }
    "l"   -> speak letter a >> return s { lMode = True }
    "s"   -> cancel p >> return s { lMode = False }
    "q" -> return s { queue = a : queue s}
    "d" -> mapM_ (speak say) (reverse (queue s)) >> return s { queue = [] }
    _ -> dispatch' >> return s { lMode = False }
  where dispatch' =
          case c of
            "tts_say" -> speak say a
            "version" -> speak say $ "Thanksgiving version " ++ version
            _         -> putStrLn ( "unknown command: " ++ c)
        speak :: (String -> String) -> String -> IO ()
        speak f [] = return ()
        speak f t  = when (lMode s) (cancel p)
                     >> toFestival ("(tts_text \"<SABLE>"
                                    ++ f (escape t)
                                    ++ "</SABLE>\" 'sable)") p

escape :: String -> String
escape = replace "\"" "\\\""

say :: String -> String
say =  replace "[*]" " "

letter :: String -> String
letter x = "<SAYAS MODE=\\\"literal\\\">" ++
           x ++ "</SAYAS>"

cancel = toFestival "(audio_mode 'shutup)"

main :: IO ()
main = process (\ p -> listener p defaultArg)
