defmodule Earmark.Transform do

  import Earmark.Helpers, only: [replace: 3]

  alias Earmark.Options

  @compact_tags ~w[a code em strong del]

  # https://www.w3.org/TR/2011/WD-html-markup-20110113/syntax.html#void-element
  @void_elements ~W(area base br col command embed hr img input keygen link meta param source track wbr)

  @moduledoc """
  # Transformations
 
  ## Structure Conserving Transformers

  For the convenience of processing the output of `EarmarkParser.as_ast` we expose two structure conserving
  mappers.

  ### `map_ast`
  
  takes a function that will be called for each node of the AST, where a leaf node is either a quadruple
  like `{"code", [{"class", "inline"}], ["some code"], %{}}` or a text leaf like `"some code"`

  The result of the function call must be

  - for nodes → a quadruple of which the third element will be ignored -- that might change in future,
  and will therefore classically be `nil`. The other elements replace the node

  - for strings → strings

  A third parameter `ignore_strings` which defaults to `false` can be used to avoid invocation of the mapper
  function for text nodes

  As an example let us transform an ast to have symbol keys

        iex(0)> input = [
        ...(0)> {"h1", [], ["Hello"], %{title: true}},
        ...(0)> {"ul", [], [{"li", [], ["alpha"], %{}}, {"li", [], ["beta"], %{}}], %{}}] 
        ...(0)> map_ast(input, fn {t, a, _, m} -> {String.to_atom(t), a, nil, m} end, true)
        [ {:h1, [], ["Hello"], %{title: true}},
          {:ul, [], [{:li, [], ["alpha"], %{}}, {:li, [], ["beta"], %{}}], %{}} ]

  **N.B.** If this returning convention is not respected `map_ast` might not complain, but the resulting
  transformation might not be suitable for `Earmark.Transform.transform` anymore. From this follows that
  any function passed in as value of the `postprocessor:` option must obey to these conventions.

  ### `map_ast_with`

  this is like `map_ast` but like a reducer an accumulator can also be passed through.

  For that reason the function is called with two arguments, the first element being the same value
  as in `map_ast` and the second the accumulator. The return values need to be equally augmented 
  tuples.

  A simple example, annotating traversal order in the meta map's `:count` key, as we are not
  interested in text nodes we use the fourth parameter `ignore_strings` which defaults to `false`

         iex(0)>  input = [
         ...(0)>  {"ul", [], [{"li", [], ["one"], %{}}, {"li", [], ["two"], %{}}], %{}},
         ...(0)>  {"p", [], ["hello"], %{}}]
         ...(0)>  counter = fn {t, a, _, m}, c -> {{t, a, nil, Map.put(m, :count, c)}, c+1} end
         ...(0)>  map_ast_with(input, 0, counter, true) 
         {[ {"ul", [], [{"li", [], ["one"], %{count: 1}}, {"li", [], ["two"], %{count: 2}}], %{count: 0}},
           {"p", [], ["hello"], %{count: 3}}], 4}

  ## Structure Modifying Transformers

  For structure modifications a tree traversal is needed and no clear pattern of how to assist this task with
  tools has emerged yet.
  """

  @doc false
  def transform(ast, options \\ %{initial_indent: 0, indent: 2})
  def transform(ast, options) when is_list(options) do
    transform(ast, options|>Enum.into(%{initial_indent: 0, indent: 2}))
  end
  def transform(ast, options) when is_map(options) do
    options1 = options
      |> Map.put_new(:indent, 2)
    to_html(ast, options1)
  end

  @doc """
  Coming soon
  """
  def map_ast(ast, fun, ignore_strings \\ false) do
    _walk_ast(ast, fun, ignore_strings, [])
  end

  @doc """
  Coming soon
  """
  def map_ast_with(ast, value, fun, ignore_strings \\ false) do
    _walk_ast_with(ast, value, fun, ignore_strings, [])
  end


  defp maybe_add_newline(options)
  defp maybe_add_newline(%Options{compact_output: true}), do: []
  defp maybe_add_newline(_), do: ?\n

  defp to_html(ast, options) do
    _to_html(ast, options, Map.get(options, :initial_indent, 0))|> IO.iodata_to_binary
  end

  defp _to_html(ast, options, level, verbatim \\ false)
  defp _to_html({:comment, _, content, _}, options, _level, _verbatim) do
    ["<!--", Enum.intersperse(content, ?\n), "-->", maybe_add_newline(options)]
  end
  defp _to_html({"code", atts, children, meta}, options, level, _verbatim) do
    verbatim = meta |> Map.get(:verbatim, false)
    [ open_tag("code", atts),
      _to_html(children, Map.put(options, :smartypants, false), level, verbatim),
      "</code>"]
  end
  defp _to_html({tag, atts, children, _}, options, level, verbatim) when tag in @compact_tags do
    [open_tag(tag, atts),
       children
       |> Enum.map(&_to_html(&1, options, level, verbatim)),
       "</", tag, ?>]
  end
  defp _to_html({tag, atts, _, _}, options, level, _verbatim) when tag in @void_elements do
    [ make_indent(options, level), open_tag(tag, atts), maybe_add_newline(options) ]
  end
  defp _to_html(elements, options, level, verbatim) when is_list(elements) do
    elements
    |> Enum.map(&_to_html(&1, options, level, verbatim))
  end
  defp _to_html(element, options, _level, false) when is_binary(element) do
    escape(element, options)
  end
  defp _to_html(element, options, level, true) when is_binary(element) do
    [make_indent(options, level), element]
  end
  defp _to_html({"pre", atts, children, meta}, options, level, _verbatim) do
    verbatim = meta |> Map.get(:verbatim, false)
    [ make_indent(options, level),
      open_tag("pre", atts),
      _to_html(children, Map.put(options, :smartypants, false), level, verbatim),
      "</pre>", maybe_add_newline(options)]
  end
  defp _to_html({tag, atts, children, meta}, options, level, _verbatim) do
    verbatim = meta |> Map.get(:verbatim, false)
    [ make_indent(options, level),
      open_tag(tag, atts),
      maybe_add_newline(options),
      _to_html(children, options, level+1, verbatim),
      close_tag(tag, options, level)]
  end

  defp close_tag(tag, options, level) do
    [make_indent(options, level), "</", tag, ?>, maybe_add_newline(options)]
  end

  defp escape(element, options)
  defp escape("", _opions) do
    []
  end

  @dbl1_rgx ~r{(^|[-–—/\(\[\{"”“\s])'}
  @dbl2_rgx ~r{(^|[-–—/\(\[\{‘\s])\"}
  defp escape(element, %{smartypants: true} = options) do
    # Unfortunately these regexes still have to be left.
    # It doesn't seem possible to make escape_to_iodata
    # transform, for example, "--'" to "–‘" without
    # significantly complicating the code to the point
    # it outweights the performance benefit.
    element =
      element
      |> replace(@dbl1_rgx, "\\1‘")
      |> replace(@dbl2_rgx, "\\1“")

    escape = Map.get(options, :escape, true)
    escape_to_iodata(element, 0, element, [], true, escape, 0)
  end

  defp escape(element, %{escape: escape}) do
      escape_to_iodata(element, 0, element, [], false, escape, 0)
  end

  defp escape(element, _options) do
      escape_to_iodata(element, 0, element, [], false, true, 0)
  end

  defp make_att(name_value_pair, tag)
  defp make_att({name, value}, _) do
    [" ", name, "=\"", value, "\""]
  end

  defp make_indent(options, level)
  defp make_indent(%Options{compact_output: true}, _level) do
    ""
  end
  defp make_indent(%{indent: indent}, level) do
    Stream.cycle([" "])
    |> Enum.take(level*indent)
  end

  defp open_tag(tag, atts)
  defp open_tag(tag, atts) when tag in @void_elements do
    [?<, tag, Enum.map(atts, &make_att(&1, tag)), " />"]
  end
  defp open_tag(tag, atts) do
    [?<, tag, Enum.map(atts, &make_att(&1, tag)), ?>]
  end

  # Optimized HTML escaping + smartypants, insipred by Plug.HTML
  # https://github.com/elixir-plug/plug/blob/v1.11.0/lib/plug/html.ex

  # Do not escape HTML entities
  defp escape_to_iodata("&#x" <> rest, skip, original, acc, smartypants, escape, len) do
    escape_to_iodata(rest, skip, original, acc, smartypants, escape, len + 3)
  end

  escapes = [
    {?<, "&lt;"},
    {?>, "&gt;"},
    {?&, "&amp;"},
    {?", "&quot;"},
    {?', "&#39;"}
  ]

  # Can't use character codes for multibyte unicode characters
  smartypants_escapes = [
    {"---", "—"},
    {"--", "–"},
    {?', "’"},
    {?", "”"},
    {"...", "…"}
  ]

  # These match only if `smartypants` is true
  for {match, insert} <- smartypants_escapes do
    # Unlike HTML escape matches, smartypants matches may contain more than one character
    match_length = if is_binary(match), do: byte_size(match), else: 1

    defp escape_to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, true, escape, 0) do
      escape_to_iodata(rest, skip + unquote(match_length), original, [acc | unquote(insert)], true, escape, 0)
    end

    defp escape_to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, true, escape, len) do
      part = binary_part(original, skip, len)
      escape_to_iodata(rest, skip + len + unquote(match_length), original, [acc, part | unquote(insert)], true, escape, 0)
    end
  end

  for {match, insert} <- escapes do
    defp escape_to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, smartypants, true, 0) do
      escape_to_iodata(rest, skip + 1, original, [acc | unquote(insert)], smartypants, true, 0)
    end

    defp escape_to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, smartypants, true, len) do
      part = binary_part(original, skip, len)
      escape_to_iodata(rest, skip + len + 1, original, [acc, part | unquote(insert)], smartypants, true, 0)
    end
  end

  defp escape_to_iodata(<<_char, rest::bits>>, skip, original, acc, smartypants, escape, len) do
    escape_to_iodata(rest, skip, original, acc, smartypants, escape, len + 1)
  end

  defp escape_to_iodata(<<>>, 0, original, _acc, _smartypants, _escape, _len) do
    original
  end

  defp escape_to_iodata(<<>>, skip, original, acc, _smartypants, _escape, len) do
    [acc | binary_part(original, skip, len)]
  end

  @pop {:__end__}
  defp _pop_to_pop(result, intermediate \\ [])
  defp _pop_to_pop([@pop, {tag, atts, _, meta}|rest], intermediate) do
    [{tag, atts, intermediate, meta}|rest]
  end
  defp _pop_to_pop([continue|rest], intermediate) do
    _pop_to_pop(rest, [continue|intermediate])
  end

  defp _walk_ast(ast, fun, ignore_strings, result)
  defp _walk_ast([], _fun, _ignore_strings, result), do: Enum.reverse(result)
  defp _walk_ast([[]|rest], fun, ignore_strings, result) do
    _walk_ast(rest, fun, ignore_strings, _pop_to_pop(result))
  end
  defp _walk_ast([string|rest], fun, ignore_strings, result) when is_binary(string) do
    new = if ignore_strings, do: string, else: fun.(string)
    _walk_ast(rest, fun, ignore_strings, [new|result])
  end
  defp _walk_ast([{_, _, content, _}=tuple|rest], fun, ignore_strings, result) do
    {new_tag, new_atts, _, new_meta} = fun.(tuple)
    _walk_ast([content|rest], fun, ignore_strings, [@pop, {new_tag, new_atts, [], new_meta}|result])
  end
  defp _walk_ast([[h|t]|rest], fun, ignore_strings, result) do
    _walk_ast([h, t|rest], fun, ignore_strings, result)
  end

  defp _walk_ast_with(ast, value, fun, ignore_strings, result)
  defp _walk_ast_with([], value, _fun, _ignore_strings, result), do: {Enum.reverse(result), value}
  defp _walk_ast_with([[]|rest], value, fun, ignore_strings, result) do
    _walk_ast_with(rest, value, fun, ignore_strings, _pop_to_pop(result))
  end
  defp _walk_ast_with([string|rest], value, fun, ignore_strings, result) when is_binary(string) do
    if ignore_strings do
      _walk_ast_with(rest, value, fun, ignore_strings, [string|result])
    else
      {news, newv} = fun.(string, value)
      _walk_ast_with(rest, newv, fun, ignore_strings, [news|result])
    end
  end
  defp _walk_ast_with([{_, _, content, _}=tuple|rest], value, fun, ignore_strings, result) do
    {{new_tag, new_atts, _, new_meta}, new_value} = fun.(tuple, value)
    _walk_ast_with([content|rest], new_value, fun, ignore_strings, [@pop, {new_tag, new_atts, [], new_meta}|result])
  end
  defp _walk_ast_with([[h|t]|rest], value, fun, ignore_strings, result) do
    _walk_ast_with([h, t|rest], value, fun, ignore_strings, result)
  end
end
