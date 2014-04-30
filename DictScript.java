import java.io.*;
import java.util.*;

public class DictScript
{
	public static void main(String[] args) throws Throwable
	{
		Scanner in = new Scanner(new File("dictionary.txt"));
		PrintWriter out = new PrintWriter("dictionary.txt.out", "UTF-8");
		while(in.hasNext())
		{
			String word = in.next();
			if(word.length() <= 7 && word.length() >= 3)
			{
				out.print(word.toUpperCase());
				out.append('\n'); //don't use \r\n on Windows
			}
		}
		out.close();
		in.close();
	}
}
