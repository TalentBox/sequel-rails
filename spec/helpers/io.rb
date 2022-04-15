module IOSpecHelper
  def pretend_file_not_exists(pattern)
    allow(IO).to receive(:read).and_wrap_original do |m, *a|
      # if this isn't a good use for case equality I don't know what is
      pattern === a.first ? raise(Errno::ENOENT) : m.call(*a) # rubocop:disable CaseEquality
    end
    # Rails > 6.1 uses Pathname#exists? instead of rescuing read error
    allow(Pathname).to receive(:new).and_call_original
    allow(Pathname).to receive(:new).with(pattern).and_return(
      instance_double(Pathname, :exist? => false)
    )
  end
end
