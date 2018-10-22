{-# LANGUAGE ConstraintKinds            #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- | The core monad 'M' and associated constraints.
module Language.Dtfpl.M
    ( MError
    , MEnv
    , M (..)
    ) where

import           Control.Monad.Except
import           Control.Monad.Reader

import           Language.Dtfpl.Env
import           Language.Dtfpl.Err

-- | Monad that can throw 'Err'.
type MError = MonadError Err

-- | Monad that can read 'Config'.
type MEnv = MonadReader Env

-- | The core monad transformer stack.
--
-- - ExceptT for signaling errors
-- - ReaderT for accessing environment (including config)
-- - IO as base monad
newtype M a = M { runM :: ExceptT Err (ReaderT Env IO) a }
    deriving (Functor, Applicative, Monad, MError, MEnv, MonadIO)
