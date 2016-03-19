# -*- coding: utf-8 -*- #

module Rouge
  module Lexers
    class Ucl < RegexLexer
      title "ucl"
      desc 'UCL configuration language'
      tag 'ucl'
      mimetypes 'text/x-ucl'
      filenames '*.ucl'

      id = /[^\s$;{}()#]+/

      state :root do
        mixin :multiline
        rule id, Keyword::Namespace, :statement
        mixin :base
      end
      
      state :block do
        mixin :multiline
        rule /}/, Punctuation, :pop!
        rule id, Keyword::Namespace, :statement
        mixin :base
      end
      state :array do
        mixin :multiline
        rule /\]/, Punctuation, :pop!
        rule /,/, Punctuation
        mixin :base
      end

      state :statement do
        mixin :multiline
        rule /{/ do
          token Punctuation; pop!; push :block
        end

        rule /\[/ do
          token Punctuation; pop!; push :array
        end

        rule /;/, Punctuation, :pop!
        rule /\n/, Text, :pop!

        mixin :base
      end

      state :quote do
        rule /\$\{?[\w_\-]+\}?/, Name::Variable
        rule /\\./, Str::Escape
        rule /"/, Punctuation, :pop!
        rule /[^"]+/, Str::Single
      end

      state :base do
        mixin :multiline
        rule /\s+/, Text

        rule /#.*?\n/, Comment::Single
        rule /(true|false|on|off|yes|no)/, Keyword::Constant
        rule /\.[^\s\.\(\)]+/, Keyword::Reserved
        rule /\"/ do
          token Punctuation; push :quote 
        end

        rule /(\d+\.\d*|\d*\.\d+)([eE][+-]?[0-9]+)?j?/, Num::Float
        rule /\-?\d+[eE][+-]?[0-9]+j?/, Num::Float
        rule /\-?\d+\.?\d*/, Num::Float
        rule /\-?\d+[kmgdmsy]?\b/, Num::Integer

        rule /(\/[^\s{^\/]+\/)/, Str::Regex

        rule /[:=]/, Punctuation

        rule /[^#\s;{}$\\]+/, Str # catchall

        rule /[$;]/, Text
      end
      state :multiline do
        rule %r(/(\\\n)?[*].*?[*](\\\n)?/)m, Comment::Multiline
        rule /<<(\S+)\n.*\n\1\n/m, Str::Double
      end
    end
  end
end
