//
// Name: Solution Definition Language
// Description: DSL for creating templates for Visual Studio solutions & projects.
// Author: Lars Wilhelmsen <lars@sral.org)
// License: Apache License, 2.0
// Version: 0.1
//
module LarsW.Languages
{
    language SolutionDefinitionLang
    {
        syntax Main = s:Solution => s;

        syntax Solution = tSolution name:tItemName 
                          tStartBrace si:SolutionItems tEndBrace 
                          => Solution { Name { name }, valuesof(si)  };
        
        syntax SolutionItems = si:SolutionItem* => { valuesof(si) };
        
        syntax SolutionItem = si:SolutionFolder => si
                            | si:SolutionProject => si
                            | si:Import => si
                            | si:SetVariable => si;
        
        syntax SolutionFolder = tFolder name:tItemName 
                                tStartBrace items:SolutionFolderItems tEndBrace 
                                => Folder { Name { name}, items };
        
        syntax SolutionFolderItems = items:SolutionFolderItem* 
                                   => FolderItems { valuesof(items) };
        
        syntax SolutionFolderItem = item:SolutionFolder => item
                                   | item:SolutionProject => item;
        
        syntax Import = tImport fileName:tQuotedString tStatementTerminator 
                      => Import { fileName };
        
        syntax SetVariable = tSet name:tItemName value:tQuotedString tStatementTerminator
                           => SetVariable { Name { name}, Value { value} };
        
        syntax SolutionProject = tProject name:tItemName 
                                  tStartBrace items:SolutionProjectItems tEndBrace 
                                  => Project { Name { name }, valuesof(items) }
                               | tProject name:tItemName ":" template:tTemplateName 
                                  tStartBrace items:SolutionProjectItems tEndBrace 
                                  => Project { Name { name}, Template { template }, valuesof(items) };
                                  
        syntax SolutionProjectItems = items:SolutionProjectItem*
                                    => ProjectItems { valuesof(items) };
        
        syntax SolutionProjectItem = item:ProjectReferences => item
                                   | item:ProjectFolder => item;
        
        syntax ProjectReferences = tReferences tStartBrace items:ProjectReferencesItems tEndBrace => Items { valuesof(items) };
        syntax ProjectReferencesItems = items:ProjectReferencesItem* => items;
       
        syntax ProjectReferencesItem = ref:ReferenceProject => ref
                                     | ref:ReferenceFile => ref
                                     | ref:ReferenceGac => ref;
        
        syntax ReferenceProject = tProject name:tItemName tStatementTerminator => ProjectReference { name };
        syntax ReferenceFile = tFile fileName:tQuotedString tStatementTerminator => FileReference { fileName };
        syntax ReferenceGac = tGac fileName:tQuotedString tStatementTerminator => GacReference { fileName };
        
        syntax ProjectFolders = items:ProjectFolder* => items; 
        syntax ProjectFolder = tFolder folderName:tItemName tStartBrace tEndBrace => Folder { folderName };
       
        @{Classification["Keyword"]}token tSet = "set";
        @{Classification["Keyword"]}token tImport = "import";
        @{Classification["Keyword"]}token tFile = "file";
        @{Classification["Keyword"]}token tGac = "gac";
        @{Classification["Keyword"]}token tReferences = "references";
        @{Classification["Keyword"]}token tProject = "project";
        @{Classification["Keyword"]}token tSolution = "solution";
        @{Classification["Keyword"]}token tFolder = "folder";
        @{Classification["String"]}token tQuotedString = TextLiteral; //'"' ^'"'* '"';
        
        token tTemplateName = (tCharacter|".")+;
        token tItemName = tCharacter (tCharacter|tDigit|tPeriod)*;
        token tCharacter = ("a".."z" |"A".."Z");
        token tDigit = "0".."9";
        token tPeriod = ".";
        token tStatementTerminator = ";";
        token tStartBrace = "{";
        token tEndBrace = "}";
        interleave Ignore = " "|"\t"|"\r"|"\n";
        
        @{Classification["Literal"]}
        token TextLiteral =
            RegularStringLiteral  
            | VerbatimStringLiteral 
        ;

        @{Classification["String"]}
        token RegularStringLiteral = 
            '"' DoubleQuoteTextCharacter* '"'
            | "'" SingleQuoteTextCharacter* "'"
        ;

        @{Classification["String"]}
        token VerbatimStringLiteral = 
            '@' '"' DoubleQuoteTextVerbatimCharacter* '"'
            | '@' "'" SingleQuoteTextVerbatimCharacter* "'"
        ;
        
        token SingleQuoteTextCharacter =
            SingleQuoteTextSimple 
            | CharacterEscapeSimple 
            | CharacterEscapeUnicode
        ;
        
        token SingleQuoteTextSimple = ^(
                '\u0027' | // Single Quote
                '\u005C' | // Backslash
                '\u000A' | // New Line
                '\u000D' | // Carriage Return
                '\u0085' | // Next Line
                '\u2028' | // Line Separator
                '\u2029') // Paragraph Separator
        ;
        
        token SingleQuoteTextVerbatimCharacter =
            ^('\u0027') // SingleQuote
            | SingleQuoteTextVerbatimCharacterEscape
        ;
        token SingleQuoteTextVerbatimCharacterEscape = '\u0027' '\u0027';
        token SingleQuoteTextVerbatimCharacters = SingleQuoteTextVerbatimCharacter+;
 
 
        token DoubleQuoteTextCharacter =
            DoubleQuoteTextSimple 
            | CharacterEscapeSimple 
            | CharacterEscapeUnicode
        ;
        
        //token // TODO: Q660: rewrite TextSimple using NewLineCharacter
        token DoubleQuoteTextSimple = ^(
                '\u0022' | // DoubleQuote 
                '\u005C' | // Backslash
                '\u000A' | // New Line
                '\u000D' | // Carriage Return
                '\u0085' | // Next Line
                '\u2028' | // Line Separator
                '\u2029') // Paragraph Separator
        ;
        
        token DoubleQuoteTextVerbatimCharacter =
            ^('\u0022') // DoubleQuote
            | DoubleQuoteTextVerbatimCharacterEscape
        ;
        token DoubleQuoteTextVerbatimCharacterEscape = '\u0022' '\u0022';
        token DoubleQuoteTextVerbatimCharacters = DoubleQuoteTextVerbatimCharacter+;

        token CharacterEscapeSimple = '\u005C' /* Backslash */ CharacterEscapeSimpleCharacter;
        token CharacterEscapeSimpleCharacter =
            "'"        // Single Quote
            | '"'      // Double Quote
            | '\u005C' // Backslash
            | '0'      // Null
            | 'a'      // Alert
            | 'b'      // Backspace
            | 'f'      // Form Feed
            | 'n'      // New Line
            | 'r'      // Carriage Return
            | 't'      // Horizontal Tab
            | 'v'      // Vertical Tab
        ;
        token CharacterEscapeUnicode =
            "\\u"  HexDigit  HexDigit  HexDigit  HexDigit
            | "\\U"  HexDigit  HexDigit  HexDigit  HexDigit HexDigit  HexDigit  HexDigit  HexDigit
        ;

        token CommentDelimited = "/*" CommentDelimitedContent* "*/";
        token CommentDelimitedContent = 
            ^('*') 
            | '*'  ^('/')
        ;
        token CommentLine = "//" CommentLineContent*;
        // TODO: Q658: rewrite CommentLineContent using NewLineCharacter
        token CommentLineContent = ^(
                '\u000A' | // New Line
                '\u000D' | // Carriage Return
                '\u0085' | // Next Line
                '\u2028' | // Line Separator
                '\u2029') // Paragraph Separator
        ;
        
                // atoms
        token NewLine =
            '\u000A'   // New Line
            | '\u000D' // Carriage Return
            | '\u000D' '\u000A' 
            | '\u0085' // Next Line
            | '\u2028' // Line Separator
            | '\u2029' // Paragraph Separator
        ;

        @{Classification["Whitespace"]}
        token Whitespace = WhitespaceCharacter+;
        // TODO: Q278: Investigate Unicode class Zs in whitespace
        token WhitespaceCharacter =
            '\u0009'   // Horizontal Tab
            | '\u000B' // Vertical Tab
            | '\u000C' // Form Feed
            | '\u0020' // Space
            | NewLine
        ;
        
        // TODO: unicode-ize with character classes
        token UpperCase = 'A'..'Z';

        // TODO: unicode-ize with character classes
        token LowerCase = 'a'..'z';

        token Letter = UpperCase | LowerCase |'_';
            
        token Digits = Digit+;
        token Digit =  '0'..'9';

        token HexDigit = Digit | 'a'..'f' | 'A'..'F';
        token HexDigits = HexDigit+;
        
        token NewLineCharacter =
            '\u000A'   // New Line
            | '\u000D' // Carriage Return
            | '\u0085' // Next Line
            | '\u2028' // Line Separator
            | '\u2029' // Paragraph Separator
        ;
    }
}
