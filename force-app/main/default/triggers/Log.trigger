trigger Log on Log__e (after insert) {
    ((EventHandler) CommonsModule.getService(LogEventHandler.class))
        .canHandleMax(1)
        .register();
}
