_model_defs = {}

get_field_list = (model) ->
    definition = window.db_schema[model]
    definition.fields

setSelectionRange = (input, selectionStart, selectionEnd) =>
    if input.setSelectionRange
        input.focus()
        input.setSelectionRange selectionStart, selectionEnd
    else if input.createTextRange
        range = input.createTextRange()
        range.collapse true
        range.moveEnd 'character', selectionEnd
        range.moveStart 'character', selectionStart
        range.select()

setCaretToPos = (input, pos) ->
  setSelectionRange input, pos, pos

module.exports =
    get_field_list: get_field_list
    setCaretToPos: setCaretToPos
    ENTER_CODE: 13
    ESC_CODE: 27