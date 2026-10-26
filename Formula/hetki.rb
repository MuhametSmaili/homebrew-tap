class Hetki < Formula
  desc "Navigate tmux sessions and save reusable workspaces"
  homepage "https://github.com/MuhametSmaili/hetki"
  url "https://github.com/MuhametSmaili/hetki/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "fac796d30381fb328a5e1b578fe350d6bff3dd47bc113a20cee1b646d9dbd17f"
  license "MIT"
  head "https://github.com/MuhametSmaili/hetki.git", branch: "main"

  depends_on "go" => :build
  depends_on "tmux"

  on_macos do
    depends_on macos: :ventura
  end

  def install
    ENV["CGO_ENABLED"] = "0"

    commit = build.head? ? Utils.git_head : Utils::Git.get_tar_commit_id(cached_download)
    odie "Cannot determine the Hetki source commit" if commit.blank?

    build_version = build.head? ? "HEAD" : "v#{version}"
    ldflags = if (buildpath/"internal/buildinfo").directory?
      %W[
        -X github.com/MuhametSmaili/hetki/internal/buildinfo.version=#{build_version}
        -X github.com/MuhametSmaili/hetki/internal/buildinfo.commit=#{commit}
      ]
    else
      %W[
        -X github.com/MuhametSmaili/hetki/cmd.Version=#{build_version}
        -X github.com/MuhametSmaili/hetki/cmd.GitCommit=#{commit}
      ]
    end

    system "go", "build", *std_go_args(ldflags:), "."
    generate_completions_from_executable(bin/"hetki", "completion")
  end

  test do
    output = shell_output("#{bin}/hetki --version")
    expected_version = build.head? ? "HEAD" : "v#{version}"
    assert_match "hetki version #{expected_version}\n", output
    assert_match(/^commit: [0-9a-f]{40}$/, output)
    assert_match "#compdef hetki", shell_output("#{bin}/hetki completion zsh")
  end
end
