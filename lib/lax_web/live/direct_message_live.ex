defmodule LaxWeb.DirectMessageLive do
  alias Lax.Messages.Message
  use LaxWeb, {:live_view, layout: :chat}

  alias Lax.Chat
  alias Lax.Users

  import LaxWeb.ChatLive.Components
  import LaxWeb.DirectMessageLive.Components

  def render(assigns) do
    ~H"""
    <.container
      sidebar_width={sidebar_width(@current_user)}
      sidebar_min_width={384}
      sidebar_max_width={1024}
    >
      <:sidebar>
        <.sidebar_header title="Direct messages">
          <:actions>
            <.icon_button icon="hero-plus-mini" phx-click={JS.patch(~p"/direct-messages")} />
          </:actions>
        </.sidebar_header>
        <.direct_message_list>
          <.direct_message_item_row
            :for={channel <- @chat.direct_messages}
            current_user={@current_user}
            users={Chat.direct_message_users(@chat, channel)}
            latest_message={Chat.latest_message(@chat, channel)}
            selected={@live_action == :show and Chat.current?(@chat, channel)}
            phx-click={JS.patch(~p"/direct-messages/#{channel}")}
          />
        </.direct_message_list>
      </:sidebar>

      <.render_action {assigns} />
    </.container>
    """
  end

  def render_action(%{live_action: :new} = assigns) do
    ~H"""
    <.live_component
      id="new_direct_message"
      module={__MODULE__.NewDirectMessageComponent}
      current_user={@current_user}
    />
    """
  end

  def render_action(%{live_action: :show} = assigns) do
    ~H"""
    <.chat_header channel={@chat.current_channel} users_fun={&Chat.direct_message_users(@chat, &1)} />

    <.chat>
      <.message
        :for={message <- @chat.messages}
        user={message.sent_by_user}
        time={Message.show_time(message, @current_user && @current_user.time_zone)}
        message={message.text}
      />
    </.chat>

    <.live_component id="chat_component" module={LaxWeb.ChatLive.ChannelChatComponent} chat={@chat} />
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:domain, :direct_messages)
     |> assign(:chat, Chat.load(socket.assigns.current_user))}
  end

  def handle_params(%{"id" => channel_id}, _uri, socket) do
    {:noreply, update(socket, :chat, &Chat.select_channel(&1, channel_id))}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("resize", %{"width" => width}, socket) do
    {:ok, user} =
      Users.update_user_ui_settings(socket.assigns.current_user, %{
        direct_messages_sidebar_width: width
      })

    {:noreply, assign(socket, :current_user, user)}
  end

  ## Helpers

  def sidebar_width(nil), do: 500
  def sidebar_width(current_user), do: current_user.ui_settings.direct_messages_sidebar_width
end