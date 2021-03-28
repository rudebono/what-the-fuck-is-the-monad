defmodule WhatTheFuckIsTheMonad.MixProject do
  use(Mix.Project)

  def project() do
    [
      {:app, :what_the_fuck_is_the_monad},
      {:version, "0.2.0"},
      {:elixir, "~> 1.7"},
      {:deps, deps()},
      {:package, package()},
      {:name, "WhatTheFuckIsTheMonad"},
      {:source_url, "https://github.com/rudebono/what-the-fuck-is-the-monad"},
      {:description, "ELIXIR MACROS FOR FUNCTION DEFINITIONS WITH ERROR HANDLING"},
      {:docs, docs()}
    ]
  end

  def application() do
    [
      {:extra_applications, [:logger]}
    ]
  end

  defp deps() do
    [
      {:ex_doc, "~> 0.24.1", [{:only, :dev}, {:runtime, false}]}
    ]
  end

  defp package() do
    [
      {:licenses, ["MIT"]},
      {:maintainers, ["JEONG HAN SEOK"]},
      {:links, %{"GitHub" => "https://github.com/rudebono/what-the-fuck-is-the-monad"}}
    ]
  end

  defp docs() do
    [
      {:main, "readme"},
      {:extras, ["README.md"]}
    ]
  end
end
