defmodule LaxWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use LaxWeb, :controller` and
  `use LaxWeb, :live_view`.
  """
  use LaxWeb, :html

  embed_templates "layouts/*"

  ## Components

  slot :bottom, default: []
  slot :inner_block

  def sidebar(assigns) do
    ~H"""
    <div class="w-16 flex flex-col border-r border-zinc-700 py-4 space-y-4">
      <%= render_slot(@inner_block) %>
      <div :if={@bottom != []} class="flex-1" />
      <%= render_slot(@bottom) %>
    </div>
    """
  end

  attr :text, :string, required: true
  attr :icon, :string, required: true
  attr :icon_selected, :string
  attr :selected, :boolean, default: false
  attr :rest, :global, include: ~w(href method navigate patch)

  def sidebar_option(assigns) do
    ~H"""
    <.link {@rest} class="flex flex-col gap-px items-center group">
      <div class={[
        "size-8 flex items-center justify-center rounded-lg group-hover:bg-zinc-500",
        @selected && "bg-zinc-500"
      ]}>
        <.icon
          name={if @selected, do: @icon_selected, else: @icon}
          class="text-white size-4 group-hover:size-5 transition-all"
        />
      </div>
      <span class="text-2xs text-white font-semibold"><%= @text %></span>
    </.link>
    """
  end
end
