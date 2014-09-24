ace.define(
    "ace/theme/vibrant_ink",
    ["require","exports","module","ace/lib/dom"],
    function(e,t,n) {
        t.isDark=!0,
        t.cssClass="ace-vibrant-ink",
        t.cssText = ''
        + '.ace-vibrant-ink .ace_gutter {background: #1a1a1a;color: #BEBEBE}'
        + '.ace-vibrant-ink .ace_print-margin {width: 1px;background: #1a1a1a}'
        + '.ace-vibrant-ink {background-color: transparent;color: #E6E0B9}'
        + '.ace-vibrant-ink .ace_cursor {border-left: 7px solid rgba(51, 255, 0, 0.54)}'
        + '.ace-vibrant-ink .ace_overwrite-cursors .ace_cursor {border-left: 0px;border-bottom: 1px solid #E6E0B9}'
        + '.ace-vibrant-ink .ace_marker-layer .ace_selection {background: rgba(124, 230, 83, 0.24)}'
        + '.ace-vibrant-ink.ace_multiselect .ace_selection.ace_start {box-shadow: 0 0 3px 0px #0F0F0F;border-radius: 2px}'
        + '.ace-vibrant-ink .ace_marker-layer .ace_step {background: rgb(102, 82, 0)}'
        + '.ace-vibrant-ink .ace_marker-layer .ace_bracket {margin: -1px 0 0 -1px;border: 1px solid #404040}'
        + '.ace-vibrant-ink .ace_marker-layer .ace_active-line {background: #333333}'
        + '.ace-vibrant-ink .ace_gutter-active-line {background-color: #333333}'
        + '.ace-vibrant-ink .ace_marker-layer .ace_selected-word {border: 1px solid #6699CC}'
        + '.ace-vibrant-ink .ace_invisible {color: #404040}'
        + '.ace-vibrant-ink .ace_keyword,.ace-vibrant-ink .ace_meta {color: #E18243}'
        + '.ace-vibrant-ink .ace_constant,.ace-vibrant-ink .ace_constant.ace_character,.ace-vibrant-ink .ace_constant.ace_character.ace_escape,.ace-vibrant-ink .ace_constant.ace_other {color: #4DBDBD}'
        + '.ace-vibrant-ink .ace_constant.ace_numeric {color: #6EFFCB}'
        + '.ace-vibrant-ink .ace_invalid,.ace-vibrant-ink .ace_invalid.ace_deprecated {color: #CCFF33;background-color: #000000}'
        + '.ace-vibrant-ink .ace_fold {background-color: #000; border-color: #948443; margin: 4px;}'
        + '.ace-vibrant-ink .ace_entity.ace_name.ace_function,.ace-vibrant-ink .ace_support.ace_function,.ace-vibrant-ink .ace_variable {color: #FFCC00}'
        + '.ace-vibrant-ink .ace_variable.ace_parameter {font-style: italic}'
        + '.ace-vibrant-ink .ace_string {color: #B2D019}'
        + '.ace-vibrant-ink .ace_string.ace_regexp {color: #44B4CC}'
        + '.ace-vibrant-ink .ace_comment { font-style: italic; color: #999 }'
        + '.ace-vibrant-ink .ace_entity.ace_other.ace_attribute-name {font-style: italic;color: #99CC99}'
        + '.ace-vibrant-ink .ace_indent-guide {background: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAACCAYAAACZgbYnAAAAEklEQVQImWNgYGBgYNDTc/oPAALPAZ7hxlbYAAAAAElFTkSuQmCC) right repeat-y;}';

        var r = e('../lib/dom');
        r.importCssString(t.cssText,t.cssClass);
        })
