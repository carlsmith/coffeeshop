/*
    JSS processor Version 1.0.1
    
	Copyright (c) 2011 Wolfgang Schmidetzki
	
	Permission is hereby granted, free of charge, to any person obtaining a copy 
	of this software and associated documentation files (the "Software"), 
	to deal in the Software without restriction, including without limitation the rights to use, 
	copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
	and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
	INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
	DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

JSS = function (){

    function addVars(vars){
        for(var i in vars)
            this[i] = vars[i]
    }

    function addVar(property, value){
		this[property] = value
    }

	function toCSS(jss, scope){
	
		var result = {};
		
		if(typeof(jss)=="string"){
			// evaluate the JSS object:	
			try{
				eval("var jss = {" + jss +"}");
			}
			catch(e){		
				console.log(e);
				return "/*\nUnable to parse JSS: " + e + "\n*/"
			}
		}
		
		json_to_css(scope||"", jss);
	
		// output result:	
		var ret="";
		for(var a in result){
			var css = result[a];
			ret += a + " {\n"
			for(var i in css){
				var values = css[i];	// this is an array !
				for(var j=0; j<values.length; j++) 
					ret += "\t" + i + ": " + values[j] + ";\n"
			} 
			ret += "}\n"
		}
		return ret;
	
		// --------------	
	
		function json_to_css(scope, css){
			if(scope && !result[scope])
				result[scope]={};
			for(var property in css){
				var value = css[property];
				if(value instanceof Array){
					var values = value;
					for(var i=0; i<values.length; i++)
						addProperty(scope, property, values[i]);
				}
				else switch(typeof(value)){
					case "number":
					case "string":
						addProperty(scope, property, value);
						break;		
					case "object":
						var endChar = property.charAt(property.length-1);
						if(scope && (endChar=="_" || endChar=="-")){
							var variants = value;
							for(var i in variants){
								// i may be a comma separted list
								var list = i.split(/\s*,\s*/);
								for(var j=0; j<list.length; j++){
									var value = variants[i];
									if(value instanceof Array){
										var values = value;
										for(var k=0; k<values.length; k++)
											addProperty(scope, property+list[j], values[k]);
									}
									else addProperty(scope, property+list[j], variants[i]);
								}
							}
						}
						else json_to_css(makeSelectorName(scope, property), value);
						break;
					default: 
						console.log("ignoring unknown type " + typeof(value) + " in property " + property);
				}
			}
		}
		
		function makePropertyName(n){
			return n.replace(/_/g, "-");
		}
	
		function makeSelectorName(scope, name){
			var snames = [];
			var names = name.split(/\s*,\s*/);
			var scopes = scope.split(/\s*,\s*/);
			for(var s=0; s<scopes.length; s++){
				var scope = scopes[s];
				for(var i=0; i<names.length; i++){
					var name = names[i];
					if(name.charAt(0)=="&")
						snames.push(scope+name.substr(1))
					else snames.push(scope ? scope+" "+name : name)
				}
			}
			return snames.join(", ");
		}
	
		function addProperty(scope, property, value){		

			if(typeof(value)=="number")
				value = value+"px";
	
			var properties = property.split(/\s*,\s*/);
			for(var i=0; i<properties.length; i++){
				var property = makePropertyName(properties[i])
		
				if(result[scope][property])			
					result[scope][property].push(value);
				else result[scope][property]=[value];
				
				
				var specials = {
					"box-shadow": [
						"-moz-box-shadow",
						"-webkit-box-shadow"
					],
					"border-radius": [
						"-moz-border-radius",
						"-webkit-border-radius"
					],
					"border-radius-topleft": [
						"-moz-border-radius-topleft",
						"-webkit-border-top-left-radius"
					],
					"border-radius-topright": [
						"-moz-border-radius-topright",
						"-webkit-border-top-right-radius"
					],
					"border-radius-bottomleft": [
						"-moz-border-radius-bottomleft",
						"-webkit-border-bottom-left-radius"
					],
					"border-radius-bottomright": [
						"-moz-border-radius-bottomright",
						"-webkit-border-bottom-right-radius"
					]
				}
				var browser_specials = specials[property]
				for(var j=0; browser_specials && j<browser_specials.length; j++)
					addProperty(scope, browser_specials[j], value);
				
			}
		}
	}

	// utility functions:

	function linearGradient(){
		var args = [];
		for(i=0; i<arguments.length; i++)
			args.push(arguments[i]);
		args = args.join(",");
		
		return [
			"-moz-linear-gradient(" + args + ")",
			"-webkit-linear-gradient(" + args + ")"
		]
	}

	function color(color, factor){
		// color is either a string in format (#)rrggbb or an array [r,g,b]
		var f = factor||1;
		var r,g,b;
		if(typeof(color)=="string"){
			if(color.charAt(0)=="#")
				color = color.substr(1);
			r = Number("0x"+color.substr(0,2))
			g = Number("0x"+color.substr(2,2))
			b = Number("0x"+color.substr(4,2))
		}
		else if(color){
			r = color[0];
			g = color[1];
			b = color[2];
		}
		else r=g=b=0;

		r = cut(r*f);
		g = cut(g*f);
		b = cut(b*f);

		function cut(v){
			return parseInt(Math.max(Math.min(255,v),0));
		}
		
		return toHEX(r,g,b);
	}

	function toHEX(r,g,b){
		var ret = (r*256*256 + g*256 + b).toString(16);
		while(ret.length<6)
			ret = "0"+ret;
		return "#"+ret;
	}
	
	// public interface:
	return {
		toCSS: toCSS,
		addVars: addVars,
		addVar: addVar,
		linearGradient: linearGradient,
		color: color
	}
	
}()

