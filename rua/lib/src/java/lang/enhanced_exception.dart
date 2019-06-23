class EnhancedException implements Exception {
  String _message;
  /**
   * The throwable that caused this throwable to get thrown, or null if this
   * throwable was not caused by another throwable, or if the causative
   * throwable is unknown.  If this field is equal to this throwable itself,
   * it indicates that the cause of this throwable has not yet been
   * initialized.
   *
   * @serial
   * @since 1.4
   */
  Object cause;

  EnhancedException() {
    cause = this;
  }

  EnhancedException.withCause(this.cause);

  EnhancedException.withMessage(this._message);

  EnhancedException.withMessageAndCause(this._message, Object cause) {
    this.cause = cause ?? this;
  }

  /**
   * Returns a short description of this throwable.
   * The result is the concatenation of:
   * <ul>
   * <li> the {@linkplain Class#getName() name} of the class of this object
   * <li> ": " (a colon and a space)
   * <li> the result of invoking this object's {@link #getLocalizedMessage}
   *      method
   * </ul>
   * If {@code getLocalizedMessage} returns {@code null}, then just
   * the class name is returned.
   *
   * @return a string representation of this throwable.
   */
  String toString() {
    String s = this.runtimeType.toString();
    String message = getLocalizedMessage();
    return (message != null) ? (s + ": " + message) : s;
  }

  /**
   * Returns the detail message string of this throwable.
   *
   * @return  the detail message string of this {@code Throwable} instance
   *          (which may be {@code null}).
   */
  String getMessage() {
    return _message;
  }

  /**
   * Creates a localized description of this throwable.
   * Subclasses may override this method in order to produce a
   * locale-specific message.  For subclasses that do not override this
   * method, the default implementation returns the same result as
   * {@code getMessage()}.
   *
   * @return  The localized description of this throwable.
   * @since   JDK1.1
   */
  String getLocalizedMessage() {
    return getMessage();
  }

  /**
   * Returns the cause of this throwable or {@code null} if the
   * cause is nonexistent or unknown.  (The cause is the throwable that
   * caused this throwable to get thrown.)
   *
   * <p>This implementation returns the cause that was supplied via one of
   * the constructors requiring a {@code Throwable}, or that was set after
   * creation with the {@link #initCause(Throwable)} method.  While it is
   * typically unnecessary to override this method, a subclass can override
   * it to return a cause set by some other means.  This is appropriate for
   * a "legacy chained throwable" that predates the addition of chained
   * exceptions to {@code Throwable}.  Note that it is <i>not</i>
   * necessary to override any of the {@code PrintStackTrace} methods,
   * all of which invoke the {@code getCause} method to determine the
   * cause of a throwable.
   *
   * @return  the cause of this throwable or {@code null} if the
   *          cause is nonexistent or unknown.
   * @since 1.4
   */
  Object getCause() {
    return (cause == this ? null : cause);
  }
}
