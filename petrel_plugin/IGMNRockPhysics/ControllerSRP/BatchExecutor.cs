using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Threading;
using System.Windows.Forms;

namespace ControllerSRP
{
    class BatchExecutor
    {
        readonly ManualResetEvent exitEvent = new ManualResetEvent(false);
        Exception threadException = null;

        private readonly IEnumerable<Action> batch;
        private readonly Action UpdateProgress;

        public BatchExecutor(IEnumerable<Action> batch, Action progessFunc)
        {
            this.batch = batch;
            UpdateProgress = progessFunc;
        }

        public BatchExecutor(Action singleTask, Action progessFunc) :
            this(new Action[] { singleTask }, progessFunc) { }

        public bool HadExceptions => threadException != null;

        public void WaitTasks()
        {
            while (!exitEvent.WaitOne(0))
            {
                Thread.Sleep(50);

                Application.DoEvents();

                UpdateProgress?.Invoke();

                if (threadException != null) throw threadException;
            }
        }

        public void ParallelStart(bool breakOnException = true)
        {
            Task.Factory.StartNew(() =>
            {
                CancellationTokenSource cancelationSource = new CancellationTokenSource();
                ParallelOptions options = new ParallelOptions
                {
                    CancellationToken = cancelationSource.Token
                };
                Parallel.ForEach(batch, options, task =>
                {
                    try
                    {
                        task();
                    }
                    catch (Exception e)
                    {
                        var prevException = Interlocked.Exchange(ref threadException, e);
                        if ((prevException == null) && breakOnException) cancelationSource.Cancel();
                    }
                });
                if (threadException == null) exitEvent.Set();
            });

        }

        public void SequentialStart(bool breakOnException = true)
        {
            Exception firstException = null;
            Task.Factory.StartNew(() =>
            {
                foreach(var task in batch)
                {
                    try
                    {
                        task();
                    }
                    catch (Exception e)
                    {
                        if (firstException == null) Interlocked.Exchange(ref firstException, e);
                        if (breakOnException) Interlocked.Exchange(ref threadException, e);
                    }
                }
                if (firstException == null) {
                    exitEvent.Set();
                    return;
                } else {
                    Interlocked.Exchange(ref threadException, firstException);
                }
            }
            );

        }

    }

}
