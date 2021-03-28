defmodule WhatTheFuckIsTheMonad do
  defmacro __using__(_options) do
    quote do
      require(Logger)
      import(WhatTheFuckIsTheMonad)
    end
  end

  defmacro wtfitm(d, do: t, else: f) do
    quote [{:location, :keep}] do
      def unquote(d) do
        try do
          unquote(t)
        rescue
          r ->
            Logger.warn(Exception.format(:error, r, __STACKTRACE__))
            unquote(f)
        catch
          r ->
            Logger.warn(Exception.format(:error, r, __STACKTRACE__))
            unquote(f)

          k, r ->
            Logger.warn(Exception.format(:error, {k, r}, __STACKTRACE__))
            unquote(f)
        end
      end
    end
  end

  defmacro wtfitmp(d, do: t, else: f) do
    quote [{:location, :keep}] do
      defp unquote(d) do
        try do
          unquote(t)
        rescue
          r ->
            Logger.warn(Exception.format(:error, r, __STACKTRACE__))
            unquote(f)
        catch
          r ->
            Logger.warn(Exception.format(:error, r, __STACKTRACE__))
            unquote(f)

          k, r ->
            Logger.warn(Exception.format(:error, {k, r}, __STACKTRACE__))
            unquote(f)
        end
      end
    end
  end

  defmacro lhs ~> rhs do
    quote [{:location, :keep}] do
      unquote(lhs)
      |> case do
        {:ok, r} ->
          r

        r ->
          r
      end
      |> unquote(rhs)
    end
  end
end
