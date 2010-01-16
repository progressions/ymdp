# Provides an interface for helper methods to know which view is being rendered so they
# can branch conditionally.
#
class Application
  # Returns true if <tt>view</tt> is the current view which is being rendered.
  #
  def self.current_view?(view)
    current_view.downcase == view.downcase
  end
  
  # Returns the name of the current view.
  #
  def self.current_view
    @@current_view
  end
  
  # Sets the name of the current view.
  #
  def self.current_view= view
    @@current_view = view
  end
end