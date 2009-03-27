namespace LarsW.MSyntaxHighlighter
{
    using System;
    using System.Dataflow;
    using System.IO;
    using System.Linq;

    class Program
    {
        static void Main(string[] args)
        {
            string[] IgnoreClassifiers = new string[] { "Whitespace", "Literal" };
            var parser = DynamicParser.LoadFromMgx("M.mgx", "Microsoft.M.MParser");
            using (var sr = new StreamReader("Test.m"))
            using (var parseContext = new ParseContext(parser.Lexer,
                                                       parser.Parser,
                                                       parser.GraphBuilder,
                                                       ErrorReporter.Standard,
                                                       "test.M"))
            {
                var lexerReader = new LexerReader();
                if (lexerReader.Open(parseContext, sr, true))
                {
                    using (StreamWriter sw = new StreamWriter("output.html"))
                    {
                        sw.WriteLine("<html><head><style>body { font-family: Consolas; } .Keyword { font-weight: bold; } .String { color: #336699; }</style></head><body>");
                        bool eof = false;
                        while (true)
                        {
                            var tokens = lexerReader.Read();
                            foreach (var token in tokens)
                            {
                                object[] tokenInfos = parser.GetTokenInfo(token.Tag);
                                ClassificationAttribute classificationAttribute = null;
                                if (tokenInfos != null && tokenInfos.Length > 0)
                                {
                                    classificationAttribute = tokenInfos[0] as ClassificationAttribute;
                                }

                                if (token.Description.Equals("EOF"))
                                {
                                    eof = true;
                                    break;
                                }
                                if (classificationAttribute != null &&
                                    !IgnoreClassifiers.Contains(classificationAttribute.Classification))
                                {
                                    sw.Write(string.Format("<span class=\"{0}\">{1}</span>",
                                        classificationAttribute.Classification,
                                        token.GetTextString()));
                                }
                                else
                                {
                                    string output = token.GetTextString().Replace(" ", "&nbsp;").Replace("\r", "<br />");
                                    sw.Write(output);
                                }
                            }
                            if (eof)
                                break;
                        }
                        sw.WriteLine("</body></html>");
                    }
                }
                Console.WriteLine("Output generated.");
                Console.ReadLine();
            }
        }
    }
}