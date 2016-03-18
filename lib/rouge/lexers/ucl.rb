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
        rule id, Keyword, :statement
        mixin :base
      end
      
      state :block do
        rule /}/, Punctuation, :pop!
        rule id, Keyword::Namespace, :statement
        mixin :base
      end
      state :array do
        rule /\]/, Punctuation, :pop!
        rule /,/, Punctuation
        mixin :base
      end

      state :statement do
        rule /{/ do
          token Punctuation; pop!; push :block
        end

        rule /\[/ do
          token Punctuation; pop!; push :array
        end

        rule /;/, Punctuation, :pop!

        mixin :base
      end

      state :quote do
        rule /\$\{?[\w_\-]+\}?/, Name::Variable
        rule /\\./, Str::Escape
        rule /"/, Punctuation, :pop!
        rule /[^"]+/, Str # catchall
      end

      state :base do
        rule /\s+/, Text

        rule /#.*?\n/, Comment::Single
        rule %r(/(\\\n)?[*].*?[*](\\\n)?/)m, Comment::Multiline
        rule /(true|false|on|off|yes|no)/, Keyword::Constant
        rule /\.[^\s\.\(\)]+/, Keyword::Reserved
        rule /\"/ do
          token Punctuation; push :quote 
        end

        rule /(\d+\.\d*|\d*\.\d+)([eE][+-]?[0-9]+)?j?/, Num::Float
        rule /\d+[eE][+-]?[0-9]+j?/, Num::Float
        rule /\-?\d+[kmg]?\b/, Num::Integer


        rule /[0-9]+[kmg]?\b/i, Num::Integer
        rule /(\/[^\s{^\/]+\/)/, Str::Regex

        rule /[:=]/, Punctuation

        rule /[^#\s;{}$\\]+/, Str # catchall

        rule /[$;]/, Text
      end
    end
  end
end
