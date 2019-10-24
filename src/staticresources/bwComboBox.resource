/*
 * bwCombobox.resource
 *
 * jQuery UI widget plugin to generate combobox.
 *
 * 2010?		Irvin?			Initial development
 * 2011 June	Andrew Couch	Migrated from Product Picker, generalized
 *
 */
(function($) {
	jQuery.widget("ui.combobox", {
		options: {
			delay: 0
		},
		reset: function() {
			this.element.val("");
			this.input.val("");
		},
		focus: function() {
			this.input.focus();
		},
		select: function(selection) {
			var self = this;
			self.input.autocomplete(
				"source",
				{term: self.input.val()},
				function(response){
					jQuery.each( response, function(index, suggestion){
						if (selection == suggestion.value){
							self.element.val(suggestion.value);
							self.input.val(suggestion.label);
						}
					});
				}
			);
		},
		_create: function() {
			var self = this;
			
			var hidden = this.element.hide();
			hidden.wrap("<div class='combobox ui-widget'/>").wrap("<div class='comboboxWrapper'/>");
			self.input = jQuery("<input>")
				.insertAfter(hidden)
				.val(hidden.val())
				.attr("id", hidden[0].id + ":input")
				.autocomplete({
					source: self.options.source,
					delay: self.options.delay,
					minLength: 0,
					focus: function(event, ui) {
						return false;
					},
					select: function(event, ui) {
						if (ui.item && hidden.val() != ui.item.value) {							
							hidden.val(ui.item.value);
							jQuery(this).val(ui.item.label);
							self.options.onchange && self.options.onchange();
						}
						return false;
					},
					change: function(event, ui) {
						hidden.val(self.input.val());
						if ("" == self.input.val()){
							self.element.val("");
						}
					}
				})
				.addClass("ui-widget-content ui-corner-right comboboxInput");
			jQuery("<button>&nbsp;</button>")
				.attr("tabIndex", -1)
				.attr("title", "Show All Items")
				.insertAfter(self.input)
				.button({
					icons: {
						primary: "ui-icon-triangle-1-s"
					},
					text: false
				})
				.removeClass("ui-corner-all")
				.addClass("ui-corner-right ui-button-icon comboboxButton")
				.click(function() {
					 // close if already visible
					if (self.input.autocomplete("widget").is(":visible")) {
					    self.input.autocomplete("close");
					    return false;
					}
					// pass empty string as value to search for, displaying all results
					self.input.autocomplete("search", "");
					self.input.focus();
					return false;
				});
			if ("" != hidden.val()){
				self.select("");
			}
		}
	});
})(jQuery);