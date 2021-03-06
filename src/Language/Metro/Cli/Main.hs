{-# LANGUAGE ApplicativeDo   #-}
{-# LANGUAGE LambdaCase      #-}
{-# LANGUAGE RecordWildCards #-}

module Language.Metro.Cli.Main
    ( main
    ) where

import           Data.Version
import           Options.Applicative
import           System.Exit
import           System.IO
import qualified System.Path                as P

import           Language.Metro
import           Language.Metro.Config
import           Language.Metro.Log.Verb
import           Language.Metro.Util.CEPath
import           Language.Metro.Util.EPath
import           Paths_metro

data Options
    = Options
        { file          :: P.AbsRelFile
        , verbosity     :: Verb
        , internalDebug :: Bool }
    | GetVersion

main :: IO ()
main = execParser opts >>= \case
    Options {..} -> do
        cePath <- mkCEPathIO $ EPath file
        let config = Config
                { debug = internalDebug
                , mainModulePath = cePath
                , moduleSearchPaths = [EPath $ P.takeDirectory file]
                , .. }
        compile config >>= \case
            Left err -> do
                hPutStr stderr err
                exitFailure
            Right () -> pure ()
    GetVersion -> putStrLn $ name ++ " version " ++ showVersion version

name :: String
name = "metro compiler"

opts :: ParserInfo Options
opts = info ((options <|> getVersion) <**> helper) $
    fullDesc
    <> header name

options :: Parser Options
options = do
    file <- fmap P.absRel $ strArgument $
        metavar "FILE"
        <> help "Source file to compile"
    verbosity <- option auto $
        long "verbosity"
        <> short 'v'
        <> metavar "V"
        <> value 1
        <> help "Set verbosity level V (higher = more output)"
        <> showDefault
    internalDebug <- switch $
        long "internal-debug"
        <> help "Enable internal checks in the compiler"
    pure Options {..}

getVersion :: Parser Options
getVersion = flag' GetVersion $
    long "version"
    <> help "Print version and exit"
