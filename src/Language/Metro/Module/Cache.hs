{-# LANGUAGE BlockArguments      #-}
{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE GADTs               #-}
{-# LANGUAGE LambdaCase          #-}
{-# LANGUAGE PolyKinds           #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}

module Language.Metro.Module.Cache
    ( ModuleCache
    , withModuleCache
    , runModuleCache
    ) where

import           Data.Map.Strict                  (Map)
import qualified Data.Map.Strict                  as M
import           Polysemy
import           Polysemy.Reader
import           Polysemy.State
import qualified System.Path                      as P

import           Language.Metro.Interface.Changed
import           Language.Metro.Interface.Syntax
import           Language.Metro.Module.Context
import           Language.Metro.Util.CEPath
import           Language.Metro.Util.FS

data ModuleCache m a where
    LookupModuleCache :: ModuleCache m (Maybe (IMod, IChanged))
    InsertModuleCache :: (IMod, IChanged) -> ModuleCache m ()

makeSem ''ModuleCache

withModuleCache :: Member ModuleCache r
    => Sem r (IMod, IChanged) -> Sem r (IMod, IChanged)
withModuleCache compile = lookupModuleCache >>= \case
    Just res -> pure res
    Nothing -> do
        res <- compile
        insertModuleCache res
        pure res

runModuleCache :: Members '[Reader ModuleContext, FS] r
    => InterpreterFor ModuleCache r
runModuleCache = evalState @(Map P.AbsFile (IMod, IChanged)) M.empty
    . reinterpret \case
        LookupModuleCache ->
            asks (cPath . currentModulePath) >>= gets . M.lookup
        InsertModuleCache res -> do
            path <- asks $ cPath . currentModulePath
            modify' $ M.insert path res
