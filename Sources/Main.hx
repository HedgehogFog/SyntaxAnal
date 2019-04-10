package;

import kha.audio2.ogg.tools.Crc32;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;


class Expr {
		public function new(?oper: String, ?left: Expr, ?right: Expr, ?value: String){
			this.oper = oper;
			this.left = left;
			this.right = right;
			this.value = value;
		}
    	public var oper : String;

    	public var left : Expr;
    	public var right : Expr;
		public var value: String;
}

class Main {
	
	static var arr: 	Array<String>;
	static var arrExpr: Array<Expr>;

	static var n = 0;

	static function skip(expr: String){
    	while(n < expr.length && " \t\n\r".indexOf(expr.charAt(n)) >= 0 )
      		n++;
   		return (n < expr.length)? n: -1;
	}

	static var isFirst = true;

	static function update(): Void {
		if (isFirst){
			parse("2+2");
			isFirst = false;
			var str = arr[0];
			for (i in 0...arr.length - 1)
				str += arr[arr.length - 1 - i];
			trace(str);
		}
	}

	static function parse(exp: String){
		arr.push(exp);
		return parseE(exp);
	}

	static function parseE(exp: String): Expr{
		var t1 = parseT(exp);
		// if (t1 != null)
		// 	trace(t1.left + " " + t1.oper + " " + t1.right + "->");
		if (skip(exp) < 0){
			arrExpr.push(t1);
			return t1;
		}
		
		switch (exp.charAt(n)){
			case "+":
				arr.push("-> E -> T1 + E");
				arrExpr.push(new Expr("+", t1, parseE(exp)));
				n++;
				return new Expr("+", t1, parseE(exp));
			case "-":
				arr.push("-> E -> T1 - E");
				arrExpr.push(new Expr("-", t1, parseE(exp)));
				n++;
				return new Expr("-", t1, parseE(exp));				
		}

		arrExpr.push(t1);
		return t1;
	}

	static function parseT(exp: String): Expr{
		var t2 = parseT2(exp);
		if (skip(exp) < 0){
			arr.push("-> T1 -> T2");
			arrExpr.push(t2);
			return t2;
		}

		switch (exp.charAt(n)){
			case "*":
				arr.push("-> T1 -> T2 * T1");
				arrExpr.push(new Expr("*", t2, parseT(exp)));
				n++;
				return new Expr("*", t2, parseT(exp));
			case "/":
				arr.push("-> T1 -> T2 / T1");		
				arrExpr.push(new Expr("/", t2, parseT(exp)));
				n++;
				return new Expr("/", t2, parseT(exp));	
		}

		arr.push("-> T1 -> T2");
		arrExpr.push(t2);

		return t2;

	}
	
	static function parseT2(exp: String): Expr {
		if(skip(exp) < 0){
    		// this.err += "\nn="+this.n+"> parseT2: empty term";
			return null;
   		}

		if(exp.charAt(n) == "-"){
			arr.push("-> T2 -> -T3");	
			arrExpr.push(new Expr("T3", parseT3(exp)));
			
      		n++;
      		return new Expr("T3", parseT3(exp)); // T2  :-  -T3
		}           
		var t3 = parseT3(exp);

		if (t3 != null){
			arr.push("-> T2 -> T3");
			arrExpr.push(t3);
		}
		return t3;
   }
 
    static function parseT3(exp: String): Expr{
		if(skip(exp) < 0){            
      		var expr = parseE(exp);
      		if(skip(exp) < 0 || exp.charAt(n) != ")")
         		trace("ERROR");
      		else
        		n++;

      		return expr;
   		}

		if(isDigit(exp, n) ){                        
      		var n1 = n;
      		do{
				n++;   
			} while(n < exp.length && isDigit(exp, n));
			arr.push("-> N -> " + exp.substring(n1, n));
			arrExpr.push(new Expr("N", exp.substring(n1, n)));

    		return new Expr("N", exp.substring(n1, n));
   		}

      	return null;
    }

	static function isDigit(exp: String, n: Int): Bool{
		if ("0123456789".indexOf(exp.charAt(n)) != -1){
			return true;
		}

		return false;
	}
	static function render(frames: Array<Framebuffer>): Void {
		var gr = frames[0].g2;

		gr.begin();

		gr.end();
		
	}

	public static function main() {
		arr = [];
		arrExpr = [];
		System.start({title: "Project", width: 1024, height: 768}, function (_) {
			// Just loading everything is ok for small projects
			Assets.loadEverything(function () {
				// Avoid passing update/render directly,
				// so replacing them via code injection works
				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (frames) { render(frames); });
			});
		});
	}
}

