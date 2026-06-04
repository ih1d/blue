-- |
-- Module      :  Lexer
-- Copyright   :  (c) Isaac Hiram Lopez Diaz 2026
-- License     :  BSD-3-Clause (see the file LICENSE)
--
-- Maintainer  :  isaac.lopez@upr.edu
-- Stability   :  experimental
-- Portability :  portable
--
-- Tokenizer for the Blue language
module Lexer where

import Text.Parsec
import Text.Parsec.String (Parser)
import Text.Parsec.Token

blue :: TokenParser ()
blue = makeTokenParser blueDef

blueDef :: LanguageDef ()
blueDef =
    LanguageDef
        { commentStart = "",
          commentEnd = "",
          commentLine = "#",
          nestedComments = False,
          identStart = letter <|> char '_',
          identLetter = alphaNum <|> char '_',
          opStart = opLetter blueDef,
          opLetter = oneOf ":!#$%&*+./<=>?@\\^|-~",
          reservedOpNames = ops,
          reservedNames = names,
          caseSensitive = True
        }
  where
    ops = ["+", "-", "*", "^", "==", "<", ">", "<=", ">=", "/=", "="]
    names = ["and", "or", "True", "False", "if", "then", "else", "let", "in", "em"]

blueReserved :: String -> Parser ()
blueReserved = reserved blue

blueReservedOp :: String -> Parser ()
blueReservedOp = reservedOp blue

blueIdentifier :: Parser String
blueIdentifier = identifier blue

blueInteger :: Parser Integer
blueInteger = integer blue

blueStringLiteral :: Parser String
blueStringLiteral = stringLiteral blue

blueSymbol :: String -> Parser String
blueSymbol = symbol blue

blueLexeme :: Parser a -> Parser a
blueLexeme = lexeme blue

blueWhiteSpace :: Parser ()
blueWhiteSpace = whiteSpace blue

blueParens :: Parser a -> Parser a
blueParens = parens blue

blueBraces :: Parser a -> Parser a
blueBraces = braces blue

blueBrackets :: Parser a -> Parser a
blueBrackets = brackets blue

blueAngles :: Parser a -> Parser a
blueAngles = angles blue

blueSemi :: Parser String
blueSemi = semi blue

blueComma :: Parser String
blueComma = comma blue

blueColon :: Parser String
blueColon = colon blue

blueDot :: Parser String
blueDot = dot blue

blueCommaSep :: Parser a -> Parser [a]
blueCommaSep = commaSep blue

blueCommaSep1 :: Parser a -> Parser [a]
blueCommaSep1 = commaSep1 blue

blueSemiSep :: Parser a -> Parser [a]
blueSemiSep = semiSep blue

blueSemiSep1 :: Parser a -> Parser [a]
blueSemiSep1 = semiSep1 blue