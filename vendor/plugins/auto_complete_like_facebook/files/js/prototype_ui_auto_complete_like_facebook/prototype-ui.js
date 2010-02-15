/*  Prototype-UI, version trunk
 *
 *  Prototype-UI is freely distributable under the terms of an MIT-style license.
 *  For details, see the PrototypeUI web site: http://www.prototype-ui.com/
 *
 *--------------------------------------------------------------------------*/

if(typeof Prototype == 'undefined' || !Prototype.Version.match("1.6"))
    throw("Prototype-UI library require Prototype library >= 1.6.0");

(function(p) {
    var b = p.Browser, n = navigator;

    if (b.WebKit) {
        b.WebKitVersion = parseFloat(n.userAgent.match(/AppleWebKit\/([\d\.\+]*)/)[1]);
        b.Safari2 = (b.WebKitVersion < 420);
    }

    if (b.IE) {
        b.IEVersion = parseFloat(n.appVersion.split(';')[1].strip().split(' ')[1]);
        b.IE6 = b.IEVersion == 6;
        b.IE7 = b.IEVersion == 7;
    }

    p.falseFunction = function() {
        return false
    };
    p.trueFunction  = function() {
        return true
    };
})(Prototype);

/*
Namespace: UI

  Introduction:
    Prototype-UI is a library of user interface components based on the Prototype framework.
    Its aim is to easilly improve user experience in web applications.

    It also provides utilities to help developers.

  Guideline:
    - Prototype conventions are followed
    - Everything should be unobstrusive
    - All components are themable with CSS stylesheets, various themes are provided

  Warning:
    Prototype-UI is still under deep development, this release is targeted to developers only.
    All interfaces are subjects to changes, suggestions are welcome.

    DO NOT use it in production for now.

  Authors:
    - Sébastien Gruhier, <http://www.xilinus.com>
    - Samuel Lebeau, <http://gotfresh.info>
*/

var UI = {
    Abstract: { },
    Ajax: { }
};
Object.extend(Class.Methods, {
    extend: Object.extend.methodize(),

    addMethods: Class.Methods.addMethods.wrap(function(proceed, source) {
        // ensure we are not trying to add null or undefined
        if (!source) return this;

        // no callback, vanilla way
        if (!source.hasOwnProperty('methodsAdded'))
            return proceed(source);

        var callback = source.methodsAdded;
        delete source.methodsAdded;
        proceed(source);
        callback.call(source, this);
        source.methodsAdded = callback;

        return this;
    }),

    addMethod: function(name, lambda) {
        var methods = {};
        methods[name] = lambda;
        return this.addMethods(methods);
    },

    method: function(name) {
        return this.prototype[name].valueOf();
    },

    classMethod: function() {
        $A(arguments).flatten().each(function(method) {
            this[method] = (function() {
                return this[method].apply(this, arguments);
            }).bind(this.prototype);
        }, this);
        return this;
    },

    // prevent any call to this method
    undefMethod: function(name) {
        this.prototype[name] = undefined;
        return this;
    },

    // remove the class' own implementation of this method
    removeMethod: function(name) {
        delete this.prototype[name];
        return this;
    },

    aliasMethod: function(newName, name) {
        this.prototype[newName] = this.prototype[name];
        return this;
    },

    aliasMethodChain: function(target, feature) {
        feature = feature.camelcase();

        this.aliasMethod(target+"Without"+feature, target);
        this.aliasMethod(target, target+"With"+feature);

        return this;
    }
});
/*
Interface: String

*/

Object.extend(String.prototype, {
    camelcase: function() {
        var string = this.dasherize().camelize();
        return string.charAt(0).toUpperCase() + string.slice(1);
    },

    /*
    Method: makeElement
      toElement is unfortunately already taken :/

      Transforms html string into an extended element or null (when failed)

      > '<li><a href="#">some text</a></li>'.makeElement(); // => LI href#
      > '<img src="foo" id="bar" /><img src="bar" id="bar" />'.makeElement(); // => IMG#foo (first one)

    Returns:
      Extended element

  */
    makeElement: function() {
        var wrapper = new Element('div');
        wrapper.innerHTML = this;
        return wrapper.down();
    }
});
Object.extend(Array.prototype, {
    /**
   * Array#isEmpty() -> Boolean
   * Convenient method to check wether or not array is empty
   * returns: true if array is empty, false otherwise
   **/
    isEmpty: function() {
        return !this.length;
    },

    /**
   * Array#at(index) -> Object
   * Returns the element at the given index or undefined if index is out of range.
   * A negative index counts from the end.
   **/
    at: function(index) {
        return this[index < 0 ? this.length + index : index];
    },

    /**
   * Array#removeAt(index) -> Object | undefined
   * Deletes item at the given index, which may be negative
   * returns: deleted item or undefined if index is out of range
   **/
    removeAt: function(index) {
        if (-index > this.length) return;
        return this.splice(index, 1)[0];
    },

    /**
   * Array#removeIf(iterator[, context]) -> Array
   * Deletes items for which iterator returns a truthy value, bound to optional context
   * returns: array of items deleted
   **/
    removeIf: function(iterator, context) {
        for (var i = this.length - 1, objects = [ ]; i >= 0; i--)
            if (iterator.call(context, this[i], i))
                objects.push(this.removeAt(i));
        return objects.reverse();
    },

    /**
   * Array#remove(object) -> Number
   * Deletes items that are identical to given object
   * returns: number of items deleted
   **/
    remove: function(object) {
        return this.removeIf(function(member) {
            return member === object
        }).length;
    },

    /**
   * Array#insert(index, object[, ...])
   * Inserts the given objects before the element with the given index (which may be negative)
   * returns: this
   **/
    insert: function(index) {
        if (index > this.length)
            this.length = index;
        else if (index < 0)
            index = this.length + index + 1;

        this.splice.apply(this, [ index, 0 ].concat($A(arguments).slice(1)));
        return this;
    }
});

// backward compatibility
Array.prototype.empty = Array.prototype.isEmpty;
Element.addMethods({
    getScrollDimensions: function(element) {
        element = $(element);
        return {
            width:  element.scrollWidth,
            height: element.scrollHeight
        }
    },

    getScrollOffset: function(element) {
        element = $(element);
        return Element._returnOffset(element.scrollLeft, element.scrollTop);
    },

    setScrollOffset: function(element, offset) {
        element = $(element);
        if (arguments.length == 3)
            offset = {
                left: offset,
                top: arguments[2]
            };
        element.scrollLeft = offset.left;
        element.scrollTop  = offset.top;
        return element;
    },

    // returns "clean" numerical style (without "px") or null if style can not be resolved
    // or is not numeric
    getNumStyle: function(element, style) {
        var value = parseFloat($(element).getStyle(style));
        return isNaN(value) ? null : value;
    },

    // with courtesy of Tobie Langel
    //   (http://tobielangel.com/2007/5/22/prototype-quick-tip)
    appendText: function(element, text) {
        element = $(element);
        element.appendChild(document.createTextNode(String.interpret(text)));
        return element;
    }
});

document.whenReady = (function() {
    var queue = [ ];

    document.observe('dom:loaded', function() {
        queue.invoke('call', document);
        queue.clear();
        document.whenReady = function(callback) {
            callback.bind(document).defer()
        };
    });

    return function(callback) {
        queue.push(callback)
    };
})();

Object.extend(document.viewport, {
    // Alias this method for consistency
    getScrollOffset: document.viewport.getScrollOffsets,

    setScrollOffset: function(offset) {
        Element.setScrollOffset(Prototype.Browser.WebKit ? document.body : document.documentElement, offset);
    },

    getScrollDimensions: function() {
        return Element.getScrollDimensions(Prototype.Browser.WebKit ? document.body : document.documentElement);
    }
});

document.whenReady(function() {
    window.$head = $(document.getElementsByTagName('head')[0]);
    window.$body = $(document.body);
});
/*
Interface: UI.Options
  Mixin to handle *options* argument in initializer pattern.

  TODO: find a better example than Circle that use an imaginary Point function,
        this example should be used in tests too.

  It assumes class defines a property called *options*, containing
  default options values.

  Instances hold their own *options* property after a first call to <setOptions>.

  Example:
    > var Circle = Class.create(UI.Options, {
    >
    >   // default options
    >   options: {
    >     radius: 1,
    >     origin: Point(0, 0)
    >   },
    >
    >   // common usage is to call setOptions in initializer
    >   initialize: function(options) {
    >     this.setOptions(options);
    >   }
    > });
    >
    > var circle = new Circle({ origin: Point(1, 4) });
    >
    > circle.options
    > // => { radius: 1, origin: Point(1,4) }

  Accessors:
    There are builtin methods to automatically write options accessors. All those
    methods can take either an array of option names nor option names as arguments.
    Notice that those methods won't override an accessor method if already present.

     * <optionsGetter> creates getters
     * <optionsSetter> creates setters
     * <optionsAccessor> creates both getters and setters

    Common usage is to invoke them on a class to create accessors for all instances
    of this class.
    Invoking those methods on a class has the same effect as invoking them on the class prototype.
    See <classMethod> for more details.

    Example:
    > // Creates getter and setter for the "radius" options of circles
    > Circle.optionsAccessor('radius');
    >
    > circle.setRadius(4);
    > // 4
    >
    > circle.getRadius();
    > // => 4 (circle.options.radius)

  Inheritance support:
    Subclasses can refine default *options* values, after a first instance call on setOptions,
    *options* attribute will hold all default options values coming from the inheritance hierarchy.
*/

(function() {
    UI.Options = {
        methodsAdded: function(klass) {
            klass.classMethod($w(' setOptions allOptions optionsGetter optionsSetter optionsAccessor '));
        },

        // Group: Methods

        /*
      Method: setOptions
        Extends object's *options* property with the given object
    */
        setOptions: function(options) {
            if (!this.hasOwnProperty('options'))
                this.options = this.allOptions();

            this.options = Object.extend(this.options, options || {});
        },

        /*
      Method: allOptions
        Computes the complete default options hash made by reverse extending all superclasses
        default options.

        > Widget.prototype.allOptions();
    */
        allOptions: function() {
            var superclass = this.constructor.superclass, ancestor = superclass && superclass.prototype;
            return (ancestor && ancestor.allOptions) ?
            Object.extend(ancestor.allOptions(), this.options) :
            Object.clone(this.options);
        },

        /*
      Method: optionsGetter
        Creates default getters for option names given as arguments.
        With no argument, creates getters for all option names.
    */
        optionsGetter: function() {
            addOptionsAccessors(this, arguments, false);
        },

        /*
      Method: optionsSetter
        Creates default setters for option names given as arguments.
        With no argument, creates setters for all option names.
    */
        optionsSetter: function() {
            addOptionsAccessors(this, arguments, true);
        },

        /*
      Method: optionsAccessor
        Creates default getters/setters for option names given as arguments.
        With no argument, creates accessors for all option names.
    */
        optionsAccessor: function() {
            this.optionsGetter.apply(this, arguments);
            this.optionsSetter.apply(this, arguments);
        }
    };

    // Internal
    function addOptionsAccessors(receiver, names, areSetters) {
        names = $A(names).flatten();

        if (names.empty())
            names = Object.keys(receiver.allOptions());

        names.each(function(name) {
            var accessorName = (areSetters ? 'set' : 'get') + name.camelcase();

            receiver[accessorName] = receiver[accessorName] || (areSetters ?
                // Setter
                function(value) {
                    return this.options[name] = value
                } :
                // Getter
                function()      {
                    return this.options[name]
                });
        });
    }
})();


UI.PullDown = Class.create(UI.Options, {
    options: {
        className:   '',
        shadow:      false,
        position:    'over',
        cloneWidth:   false,
        beforeShow:   null,
        afterShow:    null,
        beforeUpdate: null,
        afterUpdate:  null,
        afterCreate:  null
    },

    initialize: function(container, options){
        this.setOptions(options);
        this.container = $(container);

        this.element = new Element('div', {
            className: 'UI-widget-dropdown ' + this.options.className,
            style: 'z-index:999999;position:absolute;'
        }).hide();
        this.container.insert({
            after: this.element
        })
        if (this.options.shadow)
            this.shadow = new UI.Shadow(this.element, {
                theme: this.options.shadow
            }).hide();
        else
            this.iframe = Prototype.Browser.IE ? new UI.IframeShim().hide() : null;

        this.outsideClickHandler = this.outsideClick.bind(this);
        this.placeHandler        = this.place.bind(this);
        this.hideHandler         = this.hide.bind(this);
    },

    destroy: function(){
        if (this.active)
            this.element.remove();
        this.element = null;
        this.stopObserving();
    },

    /*
    Method: insert
      Inserts a new Element to the PullDown

    Parameters:
      elem  - an DOM element

    Returns:
      this
   */
    insert: function(elem){
        return this.element.insert(elem);
    },

    /*
    Method: place
      Place the PullDown

    Parameters:
      none

    Returns:
     this
  */
    place: function(){



            this.element.clonePosition(this.container, {
                setHeight: false,
                setWidth:  this.options.cloneWidth,
                offsetTop: this.options.position == 'below' ? this.container.offsetHeight : 0
            });


        var w = this.element.getWidth();
        var h = this.element.getHeight();
        var t = parseInt(this.element.style.top);
        var l = parseInt(this.element.style.left);

        if (this.shadow)
            this.shadow.setBounds({
                top: t,
                left: l,
                width: w,
                height: h
            });
        if (this.iframe)
        {


            this.iframe.setPosition(t, l).setSize(w, h);

        }

        return this;
    },

    /*
    Method: show
    Show the PullDown

    Parameters:
      event  - (optional) Event fired the show

    Returns:
     this
  */
    show: function(event){

        if (this.active)
            return this;

        this.active = true;
        this.place();

        if (this.options.beforeShow)
            this.options.beforeShow(this);
        if (this.iframe)
            this.iframe.show();
        if (this.shadow)
            this.shadow.show();
        this.element.show();
        if (this.options.afterShow)
            this.options.afterShow(this);

        document.observe('mousedown',  this.outsideClickHandler);
        Event.observe(window,'scroll', this.placeHandler);
        Event.observe(window,'resize', this.outsideClickHandler);

        return this;
    },

    outsideClick: function(event) {
        if (event.findElement('.UI-widget-dropdown'))
            return;
    //this.hide();
    },

    /*
    Method: hide
      Hide the PullDown

    Returns:
      this
  */
    hide: function(){
        if (this.active) {
            this.active = false;
            this.element.hide();
            if (this.shadow)
                this.shadow.hide();
            if(this.iframe)
                this.iframe.hide();
        }
        this.stopObserving();
        return this;
    },

    stopObserving: function() {
        Event.stopObserving(window,'resize', this.hideHandler);
        Event.stopObserving(window,'scroll', this.placeHandler);
        document.stopObserving('click', this.outsideClickHandler);
    }
});
/*
Class: UI.Shadow
  Add shadow around a DOM element. The element MUST BE in ABSOLUTE position.

  Shadow can be skinned by CSS (see mac_shadow.css or drop_shadow.css).
  CSS must be included to see shadow.

  A shadow can have two states: focused and blur.
  Shadow shifts are set in CSS file as margin and padding of shadow_container to add visual information.

  Example:
    > new UI.Shadow("element_id");
*/
UI.Shadow = Class.create(UI.Options, {
    options: {
        theme: "mac_shadow",
        focus: false,
        zIndex: 100,
        withIFrameShim: true
    },

    /*
    Method: initialize
      Constructor, adds shadow elements to the DOM if element is in the DOM.
      Element MUST BE in ABSOLUTE position.

    Parameters:
      element - DOM element
      options - Hashmap of options
        - theme (default: mac_shadow)
        - focus (default: true)
        - zIndex (default: 100)

    Returns:
      this
  */
    initialize: function(element, options) {
        this.setOptions(options);

        this.element = $(element);
        this.create();
        this.iframe = Prototype.Browser.IE && this.options.withIFrameShim ? new UI.IframeShim() : null;

        if (Object.isElement(this.element.parentNode))
            this.render();
    },

    /*
    Method: destroy
      Destructor, removes elements from the DOM
  */
    destroy: function() {
        if (this.shadow.parentNode)
            this.remove();
    },

    // Group: Size and Position
    /*
    Method: setPosition
      Sets top/left shadow position in pixels

    Parameters:
      top -  top position in pixel
      left - left position in pixel

    Returns:
      this
  */
    setPosition: function(top, left) {
        if (this.shadowSize) {
            var shadowStyle = this.shadow.style;
            top =  parseInt(top)  - this.shadowSize.top  + this.shadowShift.top;
            left = parseInt(left) - this.shadowSize.left + this.shadowShift.left;
            shadowStyle.top  = top + 'px';
            shadowStyle.left = left + 'px';
            if (this.iframe)
                this.iframe.setPosition(top, left);
        }
        return this;
    },

    /*
    Method: setSize
      Sets width/height shadow in pixels

    Parameters:
      width  - width in pixel
      height - height in pixel

    Returns:
      this
  */
    setSize: function(width, height) {
        if (this.shadowSize) {
            try {
                var w = Math.max(0, parseInt(width) + this.shadowSize.width - this.shadowShift.width) + "px";
                this.shadow.style.width = w;
                var h = Math.max(0, parseInt(height) - this.shadowShift.height) + "px";

                // this.shadowContents[1].style.height = h;
                this.shadowContents[1].childElements().each(function(e) {
                    e.style.height = h
                });
                this.shadowContents.each(function(item){
                    item.style.width = w
                });
                if (this.iframe)
                    this.iframe.setSize(width + this.shadowSize.width - this.shadowShift.width, height + this.shadowSize.height - this.shadowShift.height);
            }
            catch(e) {
            // IE could throw an exception if called to early
            }
        }
        return this;
    },

    /*
    Method: setBounds
      Sets shadow bounds in pixels

    Parameters:
      bounds - an Hash {top:, left:, width:, height:}

    Returns:
      this
  */
    setBounds: function(bounds) {
        return this.setPosition(bounds.top, bounds.left).setSize(bounds.width, bounds.height);
    },

    /*
    Method: setZIndex
      Sets shadow z-index

    Parameters:
      zIndex - zIndex value

    Returns:
      this
  */
    setZIndex: function(zIndex) {
        this.shadow.style.zIndex = zIndex;
        return this;
    },

    // Group: Render
    /*
    Method: show
      Displays shadow

    Returns:
      this
  */
    show: function() {
        this.render();
        this.shadow.show();
        if (this.iframe)
            this.iframe.show();
        return this;
    },

    /*
    Method: hide
      Hides shadow

    Returns:
      this
  */
    hide: function() {
        this.shadow.hide();
        if (this.iframe)
            this.iframe.hide();
        return this;
    },

    /*
    Method: remove
      Removes shadow from the DOM

    Returns:
      this
  */
    remove: function() {
        this.shadow.remove();
        return this;
    },

    // Group: Status
    /*
    Method: focus
      Focus shadow.

      Change shadow shift. Shift values are set in CSS file as margin and padding of shadow_container
      to add visual information of shadow status.

    Returns:
      this
  */
    focus: function() {
        this.options.focus = true;
        this.updateShadow();
        return this;
    },

    /*
    Method: blur
      Blurs shadow.

      Change shadow shift. Shift values are set in CSS file as margin and padding of shadow_container
      to add visual information of shadow status.

    Returns:
      this
  */
    blur: function() {
        this.options.focus = false;
        this.updateShadow();
        return this;
    },

    // Private Functions
    // Adds shadow elements to DOM, computes shadow size and displays it
    render: function() {
        if (this.element.parentNode && !Object.isElement(this.shadow.parentNode)) {
            this.element.parentNode.appendChild(this.shadow);
            this.computeSize();
            this.setBounds(Object.extend(this.element.getDimensions(), this.getElementPosition()));
            this.shadow.show();
        }
        return this;
    },

    // Creates HTML elements without inserting them into the DOM
    create: function() {
        var zIndex = this.element.getStyle('zIndex');
        if (!zIndex)
            this.element.setStyle({
                zIndex: this.options.zIndex
            });
        zIndex = (zIndex || this.options.zIndex) - 1;

        this.shadowContents = new Array(3);
        this.shadowContents[0] = new Element("div")
        .insert(new Element("div", {
            className: "shadow_center_wrapper"
        }).insert(new Element("div", {
            className: "n_shadow"
        })))
        .insert(new Element("div", {
            className: "shadow_right ne_shadow"
        }))
        .insert(new Element("div", {
            className: "shadow_left nw_shadow"
        }));

        this.shadowContents[1] = new Element("div")
        .insert(new Element("div", {
            className: "shadow_center_wrapper c_shadow"
        }))
        .insert(new Element("div", {
            className: "shadow_right e_shadow"
        }))
        .insert(new Element("div", {
            className: "shadow_left w_shadow"
        }));
        this.centerElements = this.shadowContents[1].childElements();

        this.shadowContents[2] = new Element("div")
        .insert(new Element("div", {
            className: "shadow_center_wrapper"
        }).insert(new Element("div", {
            className: "s_shadow"
        })))
        .insert(new Element("div", {
            className: "shadow_right se_shadow"
        }))
        .insert(new Element("div", {
            className: "shadow_left sw_shadow"
        }));

        this.shadow = new Element("div", {
            className: "shadow_container " + this.options.theme,
            style: "position:absolute; top:-10000px; left:-10000px; display:none; z-index:" + zIndex
        })
        .insert(this.shadowContents[0])
        .insert(this.shadowContents[1])
        .insert(this.shadowContents[2]);
    },

    // Compute shadow size
    computeSize: function() {
        if (this.focusedShadowShift)
            return;
        this.shadow.show();

        // Trick to get shadow shift designed in CSS as padding
        var content = this.shadowContents[1].select("div.c_shadow").first();
        this.unfocusedShadowShift = {};
        this.focusedShadowShift = {};

        $w("top left bottom right").each(function(pos) {
            this.unfocusedShadowShift[pos] = content.getNumStyle("padding-" + pos) || 0
        }.bind(this));
        this.unfocusedShadowShift.width  = this.unfocusedShadowShift.left + this.unfocusedShadowShift.right;
        this.unfocusedShadowShift.height = this.unfocusedShadowShift.top + this.unfocusedShadowShift.bottom;

        $w("top left bottom right").each(function(pos) {
            this.focusedShadowShift[pos] = content.getNumStyle("margin-" + pos) || 0
        }.bind(this));
        this.focusedShadowShift.width  = this.focusedShadowShift.left + this.focusedShadowShift.right;
        this.focusedShadowShift.height = this.focusedShadowShift.top + this.focusedShadowShift.bottom;

        this.shadowShift = this.options.focus ? this.focusedShadowShift : this.unfocusedShadowShift;

        // Get shadow size
        this.shadowSize  = {
            top:    this.shadowContents[0].childElements()[1].getNumStyle("height"),
            left:   this.shadowContents[0].childElements()[1].getNumStyle("width"),
            bottom: this.shadowContents[2].childElements()[1].getNumStyle("height"),
            right:  this.shadowContents[0].childElements()[2].getNumStyle("width")
        };

        this.shadowSize.width  = this.shadowSize.left + this.shadowSize.right;
        this.shadowSize.height = this.shadowSize.top + this.shadowSize.bottom;

        // Remove padding
        content.setStyle("padding:0; margin:0");
        this.shadow.hide();
    },

    // Update shadow size (called when it changes from focused to blur and vice-versa)
    updateShadow: function() {
        this.shadowShift = this.options.focus ? this.focusedShadowShift : this.unfocusedShadowShift;
        var shadowStyle = this.shadow.style, pos  = this.getElementPosition(), size = this.element.getDimensions();

        shadowStyle.top  =  pos.top    - this.shadowSize.top   + this.shadowShift.top   + 'px';
        shadowStyle.left  = pos.left   - this.shadowSize.left  + this.shadowShift.left  + 'px';
        shadowStyle.width = size.width + this.shadowSize.width - this.shadowShift.width + "px";
        var h = size.height - this.shadowShift.height + "px";
        this.centerElements.each(function(e) {
            e.style.height = h
        });

        var w = size.width + this.shadowSize.width - this.shadowShift.width+ "px";
        this.shadowContents.each(function(item) {
            item.style.width = w
        });
    },

    // Get element position in integer values
    getElementPosition: function() {
        return {
            top: this.element.getNumStyle("top"),
            left: this.element.getNumStyle("left")
        }
    }
});

/*
  Class: UI.IframeShim
    Handles IE6 bug when <select> elements overlap other elements with higher z-index

  Example:
    > // creates iframe and positions it under "contextMenu" element
    > this.iefix = new UI.IframeShim().positionUnder('contextMenu');
    > ...
    > document.observe('click', function(e) {
    >   if (e.isLeftClick()) {
    >     this.contextMenu.hide();
    >
    >     // hides iframe when left click is fired on a document
    >     this.iefix.hide();
    >   }
    > }.bind(this))
    > ...
*/

// TODO:
//
// Maybe it makes sense to bind iframe to an element
// so that it automatically calls positionUnder method
// when the element it's binded to is moved or resized
// Not sure how this might affect overall perfomance...

UI.IframeShim = Class.create(UI.Options, {

    options: {
        parent: document.body
    },

    /*
    Method: initialize
    Constructor

      Creates iframe shim and appends it to the body.
      Note that this method does not perform proper positioning and resizing of an iframe.
      To do that use positionUnder method

    Returns:
      this
  */
    initialize: function(options) {
        this.setOptions(options);

        this.element = new Element('iframe', {
            style: 'position:absolute;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=1);',
            src: 'javascript:false;',
            frameborder: 0
        });
        $(this.options.parent || document.body).insert(this.element);

    },

    /*
    Method: hide
      Hides iframe shim leaving its position and dimensions intact

    Returns:
      this
  */
    hide: function() {
        this.element.hide();
        return this;
    },

    /*
    Method: show
      Show iframe shim leaving its position and dimensions intact

    Returns:
      this
  */
    show: function() {
        this.element.show();
        return this;
    },

    /*
    Method: positionUnder
      Positions iframe shim under the specified element
      Sets proper dimensions, offset, zIndex and shows it
      Note that the element should have explicitly specified zIndex

    Returns:
      this
  */
    positionUnder: function(element) {
        var element = $(element),
        offset = element.cumulativeOffset(),
        dimensions = element.getDimensions(),
        style = {
            left: offset[0] + 'px',
            top: offset[1] + 'px',
            width: dimensions.width + 'px',
            height: dimensions.height + 'px',
            zIndex: element.getStyle('zIndex') - 1
        };
        this.element.setStyle(style).show();

        return this;
    },

    /*
    Method: setBounds
      Sets element's width, height, top and left css properties using 'px' as units

    Returns:
      this
  */
    setBounds: function(bounds) {
        for (prop in bounds) {
            bounds[prop] = parseInt(bounds[prop]) + 'px';
        }
        this.element.setStyle(bounds);
        return this;
    },

    /*
    Method: setSize
      Sets element's width, height

    Returns:
      this
  */
    setSize: function(width, height) {
        this.element.style.width  = parseInt(width) + "px";
        this.element.style.height = parseInt(height) + "px";
        return this;
    },

    /*
    Method: setPosition
      Sets element's top and left

    Returns:
      this
  */
    setPosition: function(top, left) {
        this.element.style.top  = parseInt(top) + "px";
        this.element.style.left = parseInt(left) + "px";
        return this;
    },

    /*
    Method: destroy
      Completely removes the iframe shim from the document

    Returns:
      this
  */
    destroy: function() {
        if (this.element)
            this.element.remove();
        return this;
    }
});
/*
  Credits:
  - Idea: Facebook + Apple Mail
  - Guillermo Rauch: Original MooTools script
  - InteRiders: Prototype version  <http://interiders.com/>
*/

Object.extend(Event, {
    KEY_SPACE: 32,
    KEY_COMA:  188
});

UI.AutoComplete = Class.create(UI.Options, {
    // Group: Options
    options: {
        className: "pui-autocomplete",         // CSS class name prefix
        max: {
            selection: 10,
            selected:false
        },  // Max values fort autocomplete,
        // selection : max item in pulldown menu
        // selected  : max selected items (false = no limit)
        url: false,                            // Url for ajax completion
        delay: 0.2,                            // Delay before running ajax request
        shadow: false,                         // Shadow theme name (false = no shadow)
        highlight: false,                      // Highlight search string in list
        tokens: false,                         // Tokens used to automatically adds a new entry (ex tokens:[KEY_COMA, KEY_SPACE] for coma and spaces)
        unique: true                           // Do not display in suggestion a selected value
    },

    initialize: function(element, options) {
        this.setOptions(options);
        if(typeof(this.options.tokens) == 'number')
            this.options.tokens = $A([this.options.tokens]);
        this.element = $(element);

        this.render();
        this.updateInputSize();
        this.nbSelected = 0;
        this.list = [];

        this.keydownHandler  = this.keydown.bindAsEventListener(this);
        document.observe('keydown', this.keydownHandler);
    },

    destroy:function() {
        this.autocompletion.destroy();
        this.input.stopObserving();
        document.stopObserving('keypress', this.keydownHandler);
        this.container.remove();
        this.element.show();
    },

    init: function(tokens) {
        tokens = tokens || this.options.tokens;
        var values = this.input.value.split(tokens.first());
        values.each(function(text) {
            if (!text.empty()) this.add(text)
        }.bind(this));
        this.input.clear();

        return this;
    },

    add: function(text, value, options) {
        // No more than max
        if (!this.canAddMoreItems())
            return;

        // Create a new li
        var li = new Element("li", Object.extend({
            className: this.getClassName("box")
        }, options || {}));
        li.observe("click",     this.focus.bindAsEventListener(this, li))
        .observe("mouseover", this.over.bindAsEventListener(this, li))
        .observe("mouseout",  this.out.bindAsEventListener(this, li));

        // Close button
        var close = new Element('a', {
            'href': '#',
            'class': 'closebutton'
        });
        li.insert(new Element("span").update(text).insert(close));
        if (value)
            li.writeAttribute("pui-autocomplete:value", value);

        close.observe("click", this.remove.bind(this, li));

        this.input.parentNode.insert({
            before: li
        });
        this.nbSelected++;
        this.updateSelectedText().updateHiddenField();

        this.updateInputSize();
        if (!this.canAddMoreItems())
            this.hideAutocomplete().fire("selection:max_reached");
        else
            this.hideAutocomplete().fire("input:empty");

        return this.fire("element:added", {
            element: li,
            text: text,
            value: value
        });
    },

    remove: function(element) {
        element.stopObserving();

        element.remove();
        this.nbSelected--;
        this.updateSelectedText().updateHiddenField();

        this.updateInputSize();
        this.input.focus();
        return this.fire("element:removed", {
            element: element
        });
    },

    removeLast: function() {
        var element = this.container.select("li." + this.getClassName("box")).last();
        if (element)
            this.remove(element);
    },

    removeSelected: function(event) {
        if (event.element().readAttribute("type") != "text" && event.keyCode == Event.KEY_BACKSPACE) {
            this.container.select("li." + this.getClassName("box")).each(function(element) {
                if (this.isSelected(element))
                    this.remove(element);
            }.bind(this));
            if (event)
                event.stop();
        }
        return this;
    },

    focus: function(event, element) {
        if (event)
            event.stop();

        // Multi selection with shift
        if (event && !event.shiftKey)
            this.deselectAll();

        element = element || this.input;
        if (element == this.input && !this.input.readAttribute("focused")) {
            this.input.writeAttribute("focused", true);
            this.input.focus();
            this.displayCompletion();
        }
        else {
            this.out(event, element);
            element.addClassName(this.getClassName("selected"));

            // Blur input field
            if (element != this.input)
                this.blur();
        }
        return this.fire("element:focus", {
            element: element
        });
    },

    blur: function(event, element) {
        if (event)
            event.stop();

        if (!element)
            this.input.blur();

        this.hideAutocomplete();
        return this.fire("element:blur", {
            element: element
        });
    },

    over: function(event, element) {
        if (!this.isSelected(element))
            element.addClassName(this.getClassName("over"));
        if (event)
            event.stop();
        return this.fire("element:over", {
            element: element
        });
    },

    out: function(event, element) {
        if (!this.isSelected(element))
            element.removeClassName(this.getClassName("over"));
        if (event)
            event.stop();
        return this.fire("element:out", {
            element: element
        });
    },

    isSelected: function(element) {
        return element.hasClassName(this.getClassName("selected"));
    },

    deselectAll: function() {
        this.container.select("li." + this.getClassName("box")).invoke("removeClassName", this.getClassName("selected"));
        return this;
    },

    setAutocompleteList: function(list) {
        this.list = list;
        return this;
    },

    /*
    Method: fire
      Fires a autocomplete custom event automatically namespaced in "autocomplete:" (see Prototype custom events).
      The memo object contains a "autocomplete" property referring to the autocomplete.


    Parameters:
      eventName - an event name
      memo      - a memo object

    Returns:
      fired event
  */
    fire: function(eventName, memo) {
        memo = memo || { };
        memo.autocomplete = this;
        return this.input.fire('autocomplete:' + eventName, memo);
    },

    /*
    Method: observe
      Observe a autocomplete event with a handler function automatically bound to the autocomplete

    Parameters:
      eventName - an event name
      handler   - a handler function

    Returns:
      this
  */
    observe: function(eventName, handler) {
        this.input.observe('autocomplete:' + eventName, handler.bind(this));
        return this;
    },

    /*
    Method: stopObserving
      Unregisters a autocomplete event, it must take the same parameters as this.observe (see Prototype stopObserving).

    Parameters:
      eventName - an event name
      handler   - a handler function

    Returns:
      this
  */
    stopObserving: function(eventName, handler) {
        this.input.stopObserving('autocomplete:' + eventName, handler);
        return this;
    },

    // PRIVATE METHOD
    // Move selection. element = nil (highlight first),  "previous"/"next" or selected element
    moveSelection: function(event, element) {
        var current = null;
        // Seletc first
        if (!this.current)
            current = this.autocompletionContainer.firstDescendant();
        else if (element == "next") {
            current = this.current[element]() || this.autocompletionContainer.firstDescendant();
        }
        else if (element == "previous") {
            current = this.current[element]() || this.autocompletionContainer.childElements().last();
        }
        else
            current = element;

        if (this.current)
            this.current.removeClassName(this.getClassName("current"));

        this.current = current;

        if (this.current)
            this.current.addClassName(this.getClassName("current"));
    },

    // Add current selected element from completion to input
    addCurrentSelected: function() {
        if (this.current) {
            // Get selected text
            var index = this.autocompletionContainer.childElements().indexOf(this.current);
            // Clear input
            this.current = null;
            this.input.value = "";

            this.add(this.selectedList[index].text, this.selectedList[index].value);

            // Refocus input
            (function() {
                this.input.focus()
            }.bind(this)).defer();
            // Clear completion (force render)
            this.displayCompletion();
        }
    },

    // Display message (info or progress)
    showMessage: function(text) {
        if (text) {
            if (this.hideTimer) {
                clearTimeout(this.hideTimer);
                this.hideTimer = false;
            }
            // udate text
            this.message.update(text);
            this.message.show();
            // Hidden auto complete suggestion
            this.autocompletionContainer.hide();
            this.showAutocomplete();
        }
        else
            this.hideAutocomplete();
    },

    // Run ajax request to get completion values
    runRequest: function(search) {
        this.autocompletionContainer.hide();
        this.fire("request:started");

        new Ajax.Request(this.options.url, {
            parameters: {
                search: search,
                max: this.options.max.selection,
                "selected[]": this.selectedValues()
            },
            onComplete: function(transport) {
                this.setAutocompleteList(transport.responseText.evalJSON());
                this.timer = null;
                this.fire("request:completed");
                this.displayCompletion();
            }.bind(this)
        });
    },

    // Get a "namespaced" class name
    getClassName: function(className) {
        return  this.options.className + "-" + className;
    },

    // Key down (for up/down and return key)
    keydown: function(event) {
        if (event.element() != this.input)
            return;

        this.ignoreKeyup = false;
        // Check max
        if (this.options.max.selected && this.nbSelected == this.options.max.selected)
            this.ignoreKeyup = true;

        // Check tokens
        if (this.options.tokens){
            var tokenFound = this.options.tokens.find(function(token){
                return event.keyCode == token;
            });
            if (tokenFound) {
                var value = this.input.value.strip();
                this.ignoreKeyup = true;
                var value = this.input.value;
                this.input.clear();
                if (!value.empty())
                    this.add(value);
            }
        }
        switch(event.keyCode) {
            case Event.KEY_UP:
                this.moveSelection(event, 'previous');
                this.ignoreKeyup = true;
                break;
            case Event.KEY_DOWN:
                this.moveSelection(event, 'next');
                this.ignoreKeyup = true;
                break;
            case Event.KEY_RETURN:
                this.addCurrentSelected();
                this.ignoreKeyup = true;
                break;
            case Event.KEY_BACKSPACE:
                if (this.input.getCaretPosition() == 0)
                    this.removeLast();
                break;
        }
        if (this.ignoreKeyup) {
            event.stop();
            return false;
        }
        else
            return true;
    },

    // Key to handle completion
    keyup: function(event) {
        if (this.ignoreKeyup) {
            this.ignoreKeyup = false;
            return true;
        }
        else {
            this.updateHiddenField();
            this.displayCompletion(event);
            return true;
        }
    },

    // Update input filed size to fit available width space
    updateInputSize: function() {
        // Get added elements width
        var top;
        var w = this.container.select("li." + this.getClassName("box")).inject(0, function(sum, element) {
            // First element
            if (Object.isUndefined(top))
                top = element.cumulativeOffset().top;
            // New line
            else if (top != element.cumulativeOffset().top) {
                top = element.cumulativeOffset().top;
                sum = 0;
            }
            return sum + element.getWidth() + element.getMarginDimensions().width + element.getBorderDimensions().width;
        });
        var margin = this.container.getMarginDimensions().width + this.container.getBorderDimensions().width + this.container.getPaddingDimensions().width;
        var width = this.container.getWidth() - w - margin;

        if (width < 50)
            width =   this.container.getWidth() - margin;

        this.input.parentNode.style.width = width + "px";
        this.input.style.width = width + "px";
    },

    // Display completion. It could display info or progress message if need be. Info when input field is empty
    // progress when ajax request is running
    displayCompletion: function(event) {

        var value = this.input.value.strip();
        this.current = null;
        if (!this.canAddMoreItems())
            return;

        if (!value.empty()) {
            // Run ajax reqest if need be
            if (event && this.options.url) {
                if (this.timer)
                    clearTimeout(this.timer);
                this.timer = this.runRequest.bind(this, value).delay(this.options.delay);
            }
            else {
                this.message.hide();
                if (this.options.url)
                    this.selectedList = this.list;
                else {
                    this.selectedList = this.list.findAll(function(entry) {
                        return entry.text.match(value)
                    }).slice(0, this.options.max.selection);
                    if (this.options.unique) {
                        var selected= this.selectedValues();
                        if (! selected.empty())
                            this.selectedList = this.selectedList.findAll(function(entry) {
                                return !selected.include(entry.value)
                            });
                    }
                }
                this.autocompletionContainer.update("");
                if (this.selectedList.empty()) {
                    this.hideAutocomplete().fire('selection:empty');
                }
                else {
                    this.selectedList.each(function(entry) {
                        var li = new Element("li").update(this.options.highlight ? entry.text.gsub(value, "<em>" + value + "</em>") : entry.text);
                        li.observe("mouseover", this.moveSelection.bindAsEventListener(this, li))
                        .observe("mousedown", this.addCurrentSelected.bindAsEventListener(this));
                        this.autocompletionContainer.insert(li);
                    }.bind(this));
                    this.autocompletionContainer.show();
                    this.moveSelection("next");

                    this.showAutocomplete();
                }
            }
        }
        else {

            this.hideAutocomplete().fire("input:empty");
        }
    },

    showAutocomplete: function(event){
        this.autocompletion.show(event);

        return this;
    },

    hideAutocomplete: function(){
        if (!this.hideTimer)
            this.hideTimer = (function() {
                this.autocompletionContainer.hide();
                this.autocompletion.hide();
                this.hideTimer = false;
            }).bind(this).defer();
        return this;
    },

    // Create HTML code
    render: function() {
        // GENERATED HTML CODE:
        // <ul class="pui-autocomplete-holder">
        //   <li class="pui-autocomplete-input">
        //     <input type="text"/>
        //   </li>
        // </ul>
        // <div class="pui-autocomplete-result">
        //   <div class="pui-autocomplete-message"></div>
        //   <ul class="pui-autocomplete-results">
        //   </ul>
        // </div>
        //
        this.input = this.element.cloneNode(true);
        this.input.writeAttribute("autocomplete", "off");
        this.input.name = "";

        this.input.observe("focus",    this.focus.bindAsEventListener(this, this.input))
        .observe("blur",     this.blur.bindAsEventListener(this, this.input))
        .observe("keyup",    this.keyup.bindAsEventListener(this));
        this.container = new Element('ul', {
            className: this.getClassName("holder")
        })
        .insert(new Element("li", {
            className: this.getClassName("input")
        }).insert(this.input));

        this.autocompletionContainer = new Element("ul",{
            className: this.getClassName("results")
        }).hide();

        this.message  = new Element("div", {
            className: this.getClassName("message")
        }).hide();
        this.hidden = new Element("input",{
            type: 'hidden',
            name: this.element.name
        });
        this.element.insert({
            before: this.container
        }).insert({
            before: this.hidden
        });
        this.element.remove();

        this.autocompletion = new UI.PullDown(this.container, {
            className: this.getClassName("result"),
            shadow: this.options.shadow,
            position: 'below',
            cloneWidth: true
        });

        this.autocompletion.insert(this.message).insert(this.autocompletionContainer);


    },

    canAddMoreItems: function() {
        return !(this.options.max.selected && this.nbSelected == this.options.max.selected);
    },

    updateSelectedText: function() {
        var selected = this.container.select("li." + this.getClassName("box"));
        var content = selected.collect(function(element) {
            return element.down("span").firstChild.textContent
        });
        var separator = this.getSeparatorChar();
        this.selectedText = content.empty() ? false : content.join(separator);

        return this;
    },

    updateHiddenField: function() {
        var separator = this.getSeparatorChar();
        this.hidden.value = this.selectedText ? this.selectedValues().join(separator) : '';
    },

    selectedValues: function() {
        var selected = this.container.select("li." + this.getClassName("box"));
        return  selected.collect(function(element) {
            return element.readAttribute("pui-autocomplete:value")
        });
    },

    getSeparatorChar: function() {
        var separator = this.options.tokens ? this.options.tokens.first() : " ";
        if (separator == Event.KEY_COMA)
            separator = ',';
        if (separator == Event.KEY_SPACE)
            separator = ' ';
        return separator;
    }
});

Element.addMethods({
    getCaretPosition: function(element) {
        if (element.createTextRange) {
            var r = document.selection.createRange().duplicate();
            r.moveEnd('character', element.value.length);
            if (r.text === '') return element.value.length;
            return element.value.lastIndexOf(r.text);
        } else return element.selectionStart;
    },

    getAttributeDimensions: function(element, attribut ) {
        var dim = $w('top bottom left right').inject({}, function(dims, key) {
            dims[key] = element.getNumStyle(attribut + "-" + key + (attribut == "border" ? "-width" : ""));
            return dims;
        });
        dim.width  = dim.left + dim.right;
        dim.height = dim.top + dim.bottom;
        return dim;
    },

    getBorderDimensions:  function(element) {
        return element.getAttributeDimensions("border")
    },
    getMarginDimensions:  function(element) {
        return element.getAttributeDimensions("margin")
    },
    getPaddingDimensions: function(element) {
        return element.getAttributeDimensions("padding")
    }
});