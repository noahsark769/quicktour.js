# The basic idea is that a user can create a tour element and pass the elements to highlight, and descriptions of them.
# After that they can let the whole thing play out or control it programatically.
class window.Quicktour

	constructor: (@item_list, options) ->
		if not options?
			options = {}
		if not @item_list?
			@item_list = []
		@init_options(options)

	init_options: (options) ->
		@elem_by_elem = options.elem_by_elem || false
		@fade_time = options.fade_time || 1000

		# frame opacity
		if options.frame_opacity? and typeof options.frame_opacity == "number" and 1 >= options.frame_opacity >= 0
			@frame_opacity = options.frame_opacity
		else
			@frame_opacity = .7

		@padding_dimensions = options.padding_dimensions ||
			top: 5
			bottom: 5
			left: 5
			right: 5
		@border_dimensions = options.border_dimensions ||
			top: 3
			bottom: 3
			right: 3
			left: 3

		@highlight_color = options.highlight_color || "#08c"
		@text_color = options.text_color || options.highlight_color || "#08c"
		@description_offset = options.description_offset ||
			top: 30
			left: 0
		@description_font = options.description_font || "'Helvetica Neue', Helvetica, sans-serif"

	addItem: (item) ->
		# add a tour item:
		# element, description
		if not item.element instanceof jQuery
			# throw error
			console.log "You have to pass jqueries."
			return null
		@item_list.push item

	setOption: (key, value) ->
		@options[key] = value
		@init_options(@options)

	resetOptions: (options) ->
		if not options?
			options = {}
		@init_options(options)

	start: ->
		width = $(document).width()
		height = $(document).height()
		console.log width
		console.log height

		# append the semi transparent background
		if not @frame
			@frame = $ "<div class='quicktour-frame'></div>"

		@frame.css "height", height
		@frame.css "width", width
		@frame.css "background-color", "rgba(0,0,0,#{@frame_opacity})"
		@frame.css "position", "absolute"
		@frame.css "top", 0
		@frame.css "left", 0
		@frame.css "display", "none" #set up for fade in

		# now append the frame and make it animate in
		$("body").append @frame
		@frame.fadeIn(@fade_in_time)

		# actually do the stuff
		console.log("starting the tour")
		for item in @item_list
			if not item.element?
				console.log "your item doesnt have an element"
				continue

			console.log "touring element:"
			offset = item.element.offset()
			console.log offset
			
			# create a new element at the same place
			new_elem = $ "<div class='quicktour-highlight'></div>"
			new_elem.css "height", item.element.height()
			new_elem.css "width", item.element.width()

			new_elem.css "position", "absolute"
			new_elem.css "left", offset.left - (item.padding_dimensions?.left || @padding_dimensions.left) - (item.border_dimensions?.left || @border_dimensions.left) + "px"
			new_elem.css "top", offset.top - (item.padding_dimensions?.top || @padding_dimensions.top) - (item.border_dimensions?.top || @border_dimensions.top) + "px"

			console.log offset.top
			console.log item.padding_dimensions?.top || @padding_dimensions.top
			console.log item.border_dimensions?.top || @border_dimensions.top

			new_elem.css "border-top", "#{if item.border_dimensions then item.border_dimensions.top else @border_dimensions.top}px solid #{@highlight_color}"
			new_elem.css "border-right", "#{if item.border_dimensions then item.border_dimensions.right else @border_dimensions.right}px solid #{@highlight_color}"
			new_elem.css "border-bottom", "#{if item.border_dimensions then item.border_dimensions.bottom else @border_dimensions.bottom}px solid #{@highlight_color}"
			new_elem.css "border-left", "#{if item.border_dimensions then item.border_dimensions.left else @border_dimensions.left}px solid #{@highlight_color}"

			# new_elem.css "padding", "#{if item.padding_dimensions then item.padding_dimensions.top else @padding_dimensions.top}px #{if item.padding_dimensions then item.padding_dimensions.right else @padding_dimensions.right}px #{if item.padding_dimensions then item.padding_dimensions.bottom else @padding_dimensions.bottom}px #{if item.padding_dimensions then item.padding_dimensions.left else @padding_dimensions.left}px"
			console.log "fucking padding top:"
			new_elem.css "padding-top", "#{item.padding_dimensions?.top || @padding_dimensions.top}"
			new_elem.css "padding-right", "#{item.padding_dimensions?.right || @padding_dimensions.right}"
			new_elem.css "padding-bottom", "#{item.padding_dimensions?.bottom || @padding_dimensions.bottom}"
			new_elem.css "padding-left", "#{item.padding_dimensions?.left || @padding_dimensions.left}"

			# append it to the frame
			@frame.append new_elem

			# now append the text descriptions
			if not item.description? then continue

			text_elem = $ "<div class='quicktour-description'>#{item.description}</div>"

			text_elem.css "position", "absolute"
			text_elem.css "top", item.element.outerHeight() + offset.top + (item.description_options?.offset?.top || @description_offset.top)
			text_elem.css "left", offset.left
			console.log offset.left

			text_elem.css "width", item.element.outerWidth()
			text_elem.css "color", "#{@text_color}"

			text_elem.css "font-family", item.description_options?.font || @description_font

			# append
			@frame.append text_elem

console.log "finished"