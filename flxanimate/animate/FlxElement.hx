package flxanimate.animate;

import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flxanimate.data.AnimationData;
import flxanimate.geom.FlxMatrix3D;

@:access(flxanimate.animate.SymbolParameters)
class FlxElement extends FlxObject implements IFlxDestroyable
{
	@:allow(flxanimate.animate.FlxKeyFrame)
	var _parent:FlxKeyFrame;
	/**
	 * All the other parameters that are exclusive to the symbol (instance, type, symbol name, etc.)
	 */
	public var symbol(default, null):SymbolParameters = null;
	/**
	 * The name of the bitmap itself.
	 */
	public var bitmap(default, set):String;
	/**
	 * The matrix that the symbol or bitmap has.
	 * **WARNING** The positions here are constant, so if you use `x` or `y`, this will concatenate to the matrix,
	 * not replace it!
	 */
	public var matrix(default, set):FlxMatrix;

	@:allow(flxanimate.FlxAnimate)
	var _matrix:FlxMatrix = new FlxMatrix();

	@:allow(flxanimate.FlxAnimate)
	var _color:ColorTransform = new ColorTransform();

	@:allow(flxanimate.FlxAnimate)
	var _scrollF:FlxPoint;



	/**
	 * Creates a new `FlxElement` instance.
	 * @param name the name of the element. `WARNING:` this name is dynamic, in other words, this name can used for the limb or the symbol!
	 * @param symbol the symbol settings, ignore this if you want to add a limb.
	 * @param matrix the matrix of the element.
	 */
	public function new(?bitmap:String = null, ?symbol:SymbolParameters = null, ?matrix:FlxMatrix = null)
	{
		super();
		this.bitmap = bitmap;
		this.symbol = symbol;
		if (symbol != null)
			symbol._parent = this;
		this.matrix = (matrix == null) ? new FlxMatrix() : matrix;

	}

	override public function toString()
	{
		return '{matrix: $matrix, bitmap: $bitmap}';
	}
	override public function destroy()
	{
		super.destroy();
		_parent = null;
		if (symbol != null)
			symbol.destroy();
		bitmap = null;
		matrix = null;
	}

	inline function set_bitmap(value:String)
	{
		if (value != bitmap && symbol != null && symbol.cacheAsBitmap)
			symbol._renderDirty = true;

		return bitmap = value;
	}
	inline function set_matrix(value:FlxMatrix)
	{
		(value == null) ? matrix.identity() : matrix = value;

		return value;
	}

	static var _updCurSym:FlxSymbol;
	public function updateRender(elapsed:Float, curFrame:Int, dictionary:Map<String, FlxSymbol>, ?swfRender:Bool = false)
	{
		if (symbol != null && (_updCurSym = dictionary.get(symbol.name)) != null)
		{
			var curFF = (symbol.type == MovieClip) ? 0 : switch (symbol.loop)
			{
				case Loop:		(symbol.firstFrame + curFrame) % _updCurSym.length;
				case PlayOnce:	cast FlxMath.bound(symbol.firstFrame + curFrame, 0, _updCurSym.length - 1);
				default:		symbol.firstFrame;
			}

			symbol.update(curFF);
			@:privateAccess
			if (symbol._renderDirty && _parent != null && _parent._cacheAsBitmap)
			{
				symbol._renderDirty = false;
				_parent._renderDirty = true;
			}
			_updCurSym.updateRender(elapsed, curFF, dictionary, swfRender);
		}
		update(elapsed);
	}

	inline extern static final _eregOpt = "i";
	inline extern static final _eregSpace = "(?:_)?";

	// Suppost Eng & Rus
	static final _eregADD		 = new EReg("add|сложение", _eregOpt);
	static final _eregALPHA		 = new EReg("alpha|альфа", _eregOpt);
	static final _eregDARKEN	 = new EReg("darken|(?:замена+" + _eregSpace + ")?теймны(м|й)", _eregOpt);
	static final _eregDIFFERENCE = new EReg("difference|разница", _eregOpt);
	static final _eregERASE		 = new EReg("erase|удаление", _eregOpt);
	static final _eregHARDLIGHT	 = new EReg("hardlight|жесткий" + _eregSpace + "свет", _eregOpt);
	static final _eregINVERT	 = new EReg("negative|invert|инверсия|негатив", _eregOpt);
	static final _eregLAYER		 = new EReg("layer|слой", _eregOpt);
	static final _eregLIGHTEN	 = new EReg("lighten|(?:замена+" + _eregSpace + ")?светлы(м|й)", _eregOpt);
	static final _eregMULTIPLY	 = new EReg("multiply|умножение", _eregOpt);
	// static final _eregNORMAL	 = new EReg("normal|нормальное", _eregOpt);
	static final _eregOVERLAY	 = new EReg("overlay|перекрытие", _eregOpt);
	static final _eregSCREEN	 = new EReg("screen|осветление", _eregOpt);
	static final _eregSUBTRACT	 = new EReg("substract|нормальное", _eregOpt);
	
	// suppost list: openfl.display.OpenGLRenderer.hx:1030

	static final _eregBlendStartKey	 = new EReg("_bl|blend" + _eregSpace + "|смешение" + _eregSpace + "|наложнение" + _eregSpace, _eregOpt);
	static final _eregBlendEndKey	 = new EReg("(?:_)?end", _eregOpt);

	public static function blendModeFromString(str:String):BlendMode
	{
		if (_eregADD.match(str))		 return BlendMode.ADD;
		if (_eregALPHA.match(str))		 return BlendMode.ALPHA;
		if (_eregDARKEN.match(str))		 return BlendMode.DARKEN;
		if (_eregDIFFERENCE.match(str))	 return BlendMode.DIFFERENCE;
		if (_eregERASE.match(str))		 return BlendMode.ERASE;
		if (_eregHARDLIGHT.match(str))	 return BlendMode.HARDLIGHT;
		if (_eregINVERT.match(str))		 return BlendMode.INVERT;
		if (_eregLAYER.match(str))		 return BlendMode.LAYER;
		if (_eregLIGHTEN.match(str))	 return BlendMode.LIGHTEN;
		if (_eregMULTIPLY.match(str))	 return BlendMode.MULTIPLY;
		if (_eregOVERLAY.match(str))	 return BlendMode.OVERLAY;
		if (_eregSCREEN.match(str))		 return BlendMode.SCREEN;
		if (_eregSUBTRACT.match(str))	 return BlendMode.SUBTRACT;
		// return BlendMode.NORMAL;
		return null;
	}
	public static function fromJSON(element:Element)
	{
		var symbol = element.SI != null;
		var params:SymbolParameters = null;
		if (symbol)
		{
			params = new SymbolParameters();
			params.instance = element.SI.IN;
			params.type = switch (element.SI.ST)
			{
				case movieclip, "movieclip": MovieClip;
				case button, "button":		 Button;
				default:					 Graphic;
			}
			if (params.instance != null && params.instance.length > 0)
			{
				if (_eregBlendStartKey.match(params.instance))
				{
					var endIsValid = _eregBlendEndKey.match(_eregBlendStartKey.matchedRight());
					params.blendMode = blendModeFromString(endIsValid ? _eregBlendEndKey.matchedLeft() : _eregBlendStartKey.matchedRight());
					// params.instance = params.instance.substring(end + 1);
				}
				else
				{
					params.blendMode = blendModeFromString(params.instance);
				}
			}
			var lp:LoopType = (element.SI.LP == null) ? loop : element.SI.LP.split("R")[0];
			params.loop = switch (lp) // remove the reverse sufix
			{
				case playonce, "playonce": PlayOnce;
				case singleframe, "singleframe": SingleFrame;
				default: Loop;
			}
			params.reverse = (element.SI.LP == null) ? false : StringTools.contains(element.SI.LP, "R");
			params.firstFrame = element.SI.FF;
			params.colorEffect = AnimationData.fromColorJson(element.SI.C);
			params.name = element.SI.SN;
			params.transformationPoint.set(element.SI.TRP.x, element.SI.TRP.y);
			params.filters = AnimationData.fromFilterJson(element.SI.F);
		}

		var m3d = (symbol) ? element.SI.M3D : element.ASI.M3D;
		var array = Reflect.fields(m3d);
		if (!Std.isOfType(m3d, Array))
			array.sort((a, b) -> Std.parseInt(a.substring(1)) - Std.parseInt(b.substring(1)));
		var m:Array<Float> = (m3d is Array) ? m3d : [for (field in array) Reflect.field(m3d,field)];

		if (!symbol && m3d == null)
		{
			m[0] = m[5] = 1;
			m[1] = m[4] = m[12] = m[13] = 0;
		}

		var pos = (symbol) ? element.SI.bitmap.POS : element.ASI.POS;
		if (pos == null)
			pos = {x: 0, y: 0};
		return new FlxElement((symbol) ? element.SI.bitmap.N : element.ASI.N, params, new FlxMatrix(m[0], m[1], m[4], m[5], m[12] + pos.x, m[13] + pos.y));
	}
}