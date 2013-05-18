# The basic idea is that a user can create a tour element and pass the elements to highlight, and descriptions of them.
# After that they can let the whole thing play out or control it programatically.
class window.Quicktour

	constructor: (options, item_list) ->
		options = options || {}
		@item_list = item_list || []
		@init_options(options)

	init_options: (options) ->
		@fade_time = options.fade_time || 500

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

		@highlight_color = options.highlight_color || "#36BBCE"
		@text_color = options.text_color || options.highlight_color || "#36BBCE"
		@description_offset = options.description_offset ||
			top: 30
			left: 0
		@description_font = options.description_font || "'Helvetica Neue', Helvetica, sans-serif"
		@set_css = if options.set_css? then options.set_css else true

		@step_through = if options.step_through? then options.step_through else true

		@title = options.title
		@title_options = options.title_options ||
			width: "100%"
			padding: "200px"
			font: "'Helvetica Neue', Halvetica, sans-serif"

	addItem: (item) ->
		# add a tour item:
		# element, description
		if not item.element instanceof jQuery
			# throw error
			return null
		@item_list.push item

	setOption: (key, value) ->
		@options[key] = value
		@init_options(@options)

	resetOptions: (options) ->
		if not options?
			options = {}
		@init_options(options)

	calculate_border: (item) ->
		right = item?.border_dimensions?.right || @border_dimensions.right
		left = item?.border_dimensions?.left || @border_dimensions.left
		top = item?.border_dimensions?.top || @border_dimensions.top
		bottom = item?.border_dimensions?.bottom || @border_dimensions.bottom

		return {
			top: top,
			bottom: bottom,
			right: right,
			left: left
		}

	calculate_padding: (item) ->
		right = item?.padding_dimensions?.right || @padding_dimensions.right
		left = item?.padding_dimensions?.left || @padding_dimensions.left
		top = item?.padding_dimensions?.top || @padding_dimensions.top
		bottom = item?.padding_dimensions?.bottom || @padding_dimensions.bottom

		rtn = {
			top: top,
			bottom: bottom,
			right: right,
			left: left
		}

		return rtn

	stop: ->
		frame = @frame
		frame.fadeOut @fade_time, ->
			frame.remove()

	start: ->
		width = $(document).width()
		height = $(document).height()

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

		# make sure frame goes away when clicked
		if not @step_through
			@frame.click ->
				_this = $(this)
				_this.fadeOut @fade_time, ->
					_this.remove()

		# actually do the stuff
		for item in @item_list
			if not item.element?
				continue

			offset = item.element.offset()
			
			# create a new element at the same place
			new_elem = $ "<div class='quicktour-highlight'></div>"
			new_elem.css "height", item.element.height()
			new_elem.css "width", item.element.width()

			padding = this.calculate_padding item
			border = this.calculate_border item

			new_elem.css "position", "absolute"
			new_elem.css "left", offset.left - padding.left - border.left + "px"
			new_elem.css "top", offset.top - padding.top - border.top + "px"

			if @set_css
				new_elem.css "border-width", "#{border.top}px #{border.right}px #{border.bottom}px #{border.left}px"
				new_elem.css "border-style", "solid"
				new_elem.css "border-color", @highlight_color

				new_elem.css "padding", "#{padding.top}px #{padding.right}px #{padding.bottom}px #{padding.left}px"

			new_elem.data("quicktour-item", item)
			item.highlight_element = new_elem

			# now append the text descriptions
			if not item.description? then continue

			text_elem = $ "<div class='quicktour-description'>#{item.description}</div>"

			text_elem.css "position", "absolute"
			text_elem.css "top", item.element.outerHeight() + offset.top + (item.description_options?.offset?.top || @description_offset.top)
			text_elem.css "left", offset.left + (item.description_options?.offset?.left || @description_offset.left)

			if @set_css
				text_elem.css "width", item.description_options?.width || item.element.outerWidth() || @description_width
				text_elem.css "color", "#{@text_color}"

			if @set_css
				text_elem.css "font-family", item.description_options?.font || @description_font

			text_elem.data("quicktour-item", item)
			item.description_element = text_elem

			# if stepping thorugh, everything is hidden initially
			if @step_through
				new_elem.css "display", "none"
				text_elem.css "display", "none"

			# append
			@frame.append new_elem
			@frame.append text_elem

		# set up step through logic
		if @step_through
			index = 0
			_this = this

			if _this.title
				title_elem = $ "<div class='quicktour-title'>#{_this.title}</div>"

				if @set_css
					title_elem.css "color", "#{@highlight_color}"
					title_elem.css "text-align", "center"
					title_elem.css "margin", "0 auto"
					title_elem.css "padding-top", @title_options.padding || "200px"
					title_elem.css "width", @title_options.width || "100%"
					title_elem.css "font-family", @title_options.font || "'Helvetica Neue', Halvetica, sans-serif"
				@frame.append title_elem

			title_showing = true
			_this.frame.click ->
				$this = $(this)

				# if we showed a title already, show the first box
				if title_showing
					_this.item_list[index].highlight_element.fadeIn(_this.fade_time)
					_this.item_list[index].description_element.fadeIn(_this.fade_time)
					if _this.title
						title_elem.fadeOut(_this.fade_time)
					title_showing = false
					return
				_this.item_list[index].highlight_element.fadeOut _this.fade_time, ->
					if index < _this.item_list.length - 1
						_this.item_list[index + 1].highlight_element.fadeIn(_this.fade_time)
						_this.item_list[index + 1].description_element.fadeIn(_this.fade_time)
					else
						$this.fadeOut _this.fade_time, ->
							$this.remove()
					index++
				_this.item_list[index].description_element.fadeOut _this.fade_time

			if not @title
				@frame.click()

		# aaaaaand we're done
		@frame.fadeIn(@fade_time)

