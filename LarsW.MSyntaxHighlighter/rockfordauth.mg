module LarsW.Languages
{
    language RockfordsAuthLang
    {
        syntax Main = ar:AuthRule* => Rules { valuesof(ar) };
        syntax AuthRule = ad:AllowDeny av:AuthVerb tOpenParen rl:RoleList tCloseParen tSemiColon
                          => AuthRule { Type {ad}, AuthType{av}, Roles { valuesof(rl)} };
        syntax RoleList = ri:RoleItem  => List { ri }
                        | ri:RoleItem tComma rl:RoleList => List { ri, valuesof(rl) };
        syntax RoleItem = tRoleName;
        syntax AllowDeny = a:tAllow => a
                         | d:tDeny => d;
        syntax AuthVerb = tText;
        token tText = ("a".."z"|"A".."Z")+;
        @{Classification["Keyword"]}token tAllow = "Allow";
        @{Classification["Keyword"]}token tDeny = "Deny";
        token tOpenParen = "(";
        token tCloseParen = ")";
        token tSemiColon = ";";
        token tComma = ",";
        token Whitespace = " "|"\t"|"\r"|"\n";
        token tRoleName = Language.Grammar.TextLiteral;
        interleave Skippable = Whitespace;
    }
}