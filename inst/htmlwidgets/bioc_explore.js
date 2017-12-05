HTMLWidgets.widget({

  name: 'bioc_explore',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        // TODO: code to render the widget, e.g.
        el.innerText = x.data.message + " " + width + " " + height;

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size
        el.innerText = x.message + " " + width + " " + height;

      }

    };
  }
});
