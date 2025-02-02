module Directories (
  getStackSubdir,
  globDirs,
  switchToSystemDirUnder
  )
where

import Control.Monad.Extra
import Data.List.Extra
import SimpleCmd (error')
import System.Directory
import System.FilePath
import System.FilePath.Glob

globDirs :: String -> IO [FilePath]
globDirs pat = do
  map (dropPrefix "./") <$> namesMatching (pat ++ "/")

getStackSubdir :: FilePath -> IO FilePath
getStackSubdir subdir = do
  home <- getHomeDirectory
  return $ home </> ".stack" </> subdir

switchToSystemDirUnder :: FilePath -> IO ()
switchToSystemDirUnder dir = do
  ifM (doesDirectoryExist dir)
    (setCurrentDirectory dir)
    (error' $ dir ++ " not found")
  systems <- listDirectory "."
  -- FIXME be more precise/check "system" dirs
  -- eg 64bit intel Linux: x86_64-linux-tinfo6
  let system = case systems of
        [] -> error' $ "No OS system in " ++ dir
        [sys] -> sys
        _ -> error' "More than one OS systems found " ++ dir ++ " (unsupported)"
  setCurrentDirectory system
