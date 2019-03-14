# frozen_string_literal: true

class HartFormBuilder < ActionView::Helpers::FormBuilder
  def labeled_text_area(name, attribute, args = {})
    @template.content_tag(:div, class: 'field form-group') do
      label(attribute, name) + text_area(attribute, args)
    end
  end

  def text_area(attribute, args = {})
    args = add_control_class args
    super(attribute, args)
  end

  def labeled_number_field(name, attribute, args = {})
    @template.content_tag(:div, class: 'field form-group') do
      label(attribute, name) + number_field(attribute, args)
    end
  end

  def number_field(attribute, args = {})
    args = add_control_class args
    super(attribute, args)
  end

  def labeled_text_field(name, attribute, args = {})
    @template.content_tag(:div, class: 'field form-group') do
      result = label(attribute, name) + text_field(attribute, args)
      if args[:description]
        result += @template.content_tag(:small, class: 'form-text text-muted') do
          args[:description]
        end
      end
      result
    end
  end

  def text_field(attribute, args = {})
    args = add_control_class args
    super(attribute, args)
  end

  def labeled_password_field(name, attribute, args = {})
    args[:value] ||= @object.send(attribute)
    @template.content_tag(:div, class: 'field form-group') do
      label(attribute, name) + password_field(attribute, args)
    end
  end

  def password_field(attribute, args = {})
    args = add_control_class args
    super(attribute, args)
  end

  def accept
    submit class: 'btn btn-primary'
  end

  private

  def add_control_class(args)
    args[:class] ||= ''
    args[:class] += ' form-control'
    args
  end
end
