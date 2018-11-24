{-
This software is distributed in BSD-3 clause

I named it Thanksgiving because today is Thanksgiving, and tomorrow is Black
Friday.
-}
module Main where


import Data.Char (isSpace)
import System.IO (isEOF)
import Control.Monad (when)
import Data.ByteString.Char8 (pack, unpack)
import Network.Simple.TCP

import Args
import Parse

server :: ((Socket, SockAddr) -> IO ()) -> IO ()
server c = initArg >>= (\(a , b) -> connect a b c)

process :: (Socket -> IO ()) -> IO ()
process p = server (\ (s,a) -> putStrLn ( "Connected to " ++ show a)
                         >> p s
                         >> return ())

toFestival :: Socket -> String -> IO ()
toFestival s x = send s $ pack x



data Context = Context
               { queue :: [String]
               , rate  :: Float
               , lMode :: Bool
               }

initParmameter = Context {queue = []
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

type Command  = String
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
    "s"   -> cancel >> return s { lMode = False, queue = [] }
    "q" -> return s { queue = a : queue s}
    "d" -> mapM_ (speak say) (reverse (queue s)) >> return s { queue = [] }
    _ -> dispatch' >> return s { lMode = False }
  where dispatch' =
          case c of
            "tts_say" -> speak say a
            "a"       -> speak playSound a
            "version" -> speak say version
            _         -> putStrLn ( "unknown command: " ++ c)
        speak :: (String -> String) -> String -> IO ()
        speak f [] = return ()
        speak f t  = when (lMode s) cancel
                     >> toFestival p (format f t)
        cancel = toFestival p "(audio_mode 'shutup)"


main :: IO ()
main = process (`listener` initParmameter)
