module Cmdline
  (initArg
  ,version) where

import System.Environment (getArgs)
import System.Exit (exitWith, ExitCode (ExitSuccess,ExitFailure))

version :: String
version = "Thanksgiving version " ++ "0.1.0.0"

usage = putStrLn "Usage: tksgiv [-vh] [hostname] [port]"

initArg :: IO (String, String)
initArg = getArgs >>= parse

parse :: [String] -> IO (String, String)
parse ["-h"] = usage >> exitWith ExitSuccess
parse ["-v"] = putStrLn version >> exitWith ExitSuccess
parse []     = return ("localhost", "1314")
parse [a,b]  = return (a,b)
parse _ = putStrLn "Unknown arguments."
          >> exitWith (ExitFailure 255)
