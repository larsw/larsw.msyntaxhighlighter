//
// Name: Solution Definition Language
// Description: DSL for creating templates for Visual Studio solutions & projects.
// Author: Lars Wilhelmsen <lars@sral.org)
// License: Apache License, 2.0
// Version: 0.1
//
module LarsW.Languages
{
    import Language;
    
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
        @{Classification["String"]}token tQuotedString = Grammar.TextLiteral;
        
        token tTemplateName = (tCharacter|".")+;
        token tItemName = tCharacter (tCharacter|tDigit|tPeriod)*;
        token tCharacter = ("a".."z" |"A".."Z");
        token tDigit = "0".."9";
        token tPeriod = ".";
        token tStatementTerminator = ";";
        token tStartBrace = "{";
        token tEndBrace = "}";
        interleave Ignore = " "|"\t"|"\r"|"\n";
    }
}
