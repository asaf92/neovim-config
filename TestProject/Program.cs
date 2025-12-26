using System;

var x = DoesNotExist(123); // should produce a diagnostic + possible code action(s)
Console.WriteLine(x);
