-- |
-- * Tree languages.

module CoALP.TreeLang
       (
         -- | Types.
         TreeLang,
         TreeWord,
         TreeSymb,
         -- | Operations on languages (extendible list).
         empty,
         (\:),
         -- | Correctness check.
         treeLang,
       ) where

import Prelude hiding (foldr, zip, length, all, drop)

import Data.Sequence (Seq, ViewR(..), (|>), viewr, length, zip, drop)
import Data.Set      (Set, member)
import qualified Data.Set as Set
import Data.Foldable
import Data.Word

type TreeLang = Set TreeWord  -- ^ A tree language is a set of words.
type TreeWord = Seq TreeSymb  -- ^ A word is a list of symbols.
type TreeSymb = Word64        -- ^ A symbol is an unsigned integer.

empty :: TreeLang
empty = Set.empty

-- ^ Tree sub-language (left quotient) at a given word.
(\:) :: TreeWord -> TreeLang -> TreeLang
(\:) w = foldr quotients empty
  where
    len = length w
    quotients u =
      let pairs = u `zip` w in
      if length pairs == len && all (uncurry (==)) pairs then
        Set.insert $ drop len u
      else id

-- | Run-time check of a set against the definition of term tree. The finite
-- branching property is not checked because the number of children of a tree
-- node is at most 2^64 for 'Word64'.
treeLang :: TreeLang -> Bool
treeLang l = Set.foldr check True l
  where
    check w b = case viewr w of
      EmptyR -> b
      v :> 0 -> v `member` l
      v :> i -> (v |> i - 1) `member` l
