{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Control.Applicative
import           Snap.Core
import           Snap.Util.FileServe
import           Snap.Http.Server
import           Network.WebSockets
import           Network.WebSockets.Snap
import           System.FSNotify
import           Control.Concurrent.Chan
import           Control.Concurrent(forkIO)
import           Control.Monad(void,forever)
import           Data.Text.Lazy(pack)
import           Filesystem.Path.CurrentOS(encodeString,decodeString)
import           System.Directory
import           System.Environment(getArgs)
import           System.FilePath(makeRelative)

main :: IO ()
main = withManager $ \mgr -> do
    args <- getArgs
    cwd <- if null args then getCurrentDirectory else canonicalizePath $ head args
    putStrLn $ "Serving directory " ++ cwd
    chan <- newChan
    _ <- watchTreeChan mgr (decodeString cwd) (const True) chan
    printChanges chan
    quickHttpServe $
        path "//__index.html" (serveFile "frame.html") <|>
        path "__ws" (runWebSocketsSnap $ ws cwd chan) <|>
        serveDirectory cwd

ws :: String -> EventChannel -> ServerApp
ws cwd chan' pending = do
    chan <- dupChan chan'
    conn <- acceptRequest pending
    sendTextData conn $ pack "index.html"
    forever $ do
        res <- readChan chan
        let res_path = makeRelative cwd $ encodeString $ eventPath res
        sendTextData conn $ pack res_path

printChanges :: EventChannel -> IO ()
printChanges chan = void $ forkIO $ forever $ do
    res <- readChan chan
    print res
